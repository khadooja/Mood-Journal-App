import 'journal_state.dart';
import '../services/ai_service.dart';
import '../models/journal_entry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/journal_repository.dart';

/// Owns all business logic for the journal feature.
/// Screens will call these methods — never the repository directly.
class JournalCubit extends Cubit<JournalState> {
  List<JournalEntry> _allEntries = [];
  final JournalRepository _repository;
  final AiService _aiService;

  JournalCubit({
    required JournalRepository repository,
    required AiService aiService,
  }) : _repository = repository,
       _aiService = aiService,
       super(const JournalInitial());

  /// Fetches all entries and emits [JournalLoaded].
  /// Called once on app start, and again after any write operation.
  Future<void> loadEntries() async {
    emit(const JournalLoading());
    try {
      final entries = await _repository.loadEntries();
      emit(JournalLoaded(entries));
    } catch (e) {
      emit(JournalError('Could not load entries: $e'));
    }
  }

  /// Persists a new entry then reloads so the list stays in sync.
  Future<void> addEntry(JournalEntry entry) async {
    try {
      await _repository.addEntry(entry);
      await loadEntries();
    } catch (e) {
      emit(JournalError('Could not save entry: $e'));
    }
  }

  /// Removes an entry by id then reloads.
  Future<void> deleteEntry(String id) async {
    try {
      await _repository.deleteEntry(id);
      await loadEntries();
    } catch (e) {
      emit(JournalError('Could not delete entry: $e'));
    }
  }

  /// Sends [text] to the AI service and returns a structured mood analysis.
  ///
  /// Returns a [Map] with keys: moodIndex, label, confidence, insight.
  /// Throws [AiServiceException] on network / API failure — callers should
  /// catch and handle this (e.g. show a snackbar in the UI).
  /// Does NOT emit state — the result is returned directly so the UI
  /// can handle it locally without disrupting the journal entry list.
  Future<Map<String, dynamic>> analyzeEntry(String text) {
    return _aiService.analyzeMood(text);
  }

  /// Filters the current loaded entries by [query] (note text)
  /// and optionally by [moodIndex].
  /// Does NOT reload from Hive — filters in-memory only.
  void searchEntries({String query = '', int? moodIndex}) {
    final current = state;
    if (current is! JournalLoaded) return;

    // Always re-load all entries first so clearing search restores full list
    _repository.loadEntries().then((all) {
      final filtered = all.where((entry) {
        final matchesText =
            query.isEmpty ||
            entry.note.toLowerCase().contains(query.toLowerCase());
        final matchesMood = moodIndex == null || entry.moodIndex == moodIndex;
        return matchesText && matchesMood;
      }).toList();

      emit(JournalLoaded(filtered));
    });
  }

  /// Updates an existing entry in place, then reloads the list.
  Future<void> updateEntry(JournalEntry entry) async {
    try {
      await _repository.updateEntry(entry);
      await loadEntries();
    } catch (e) {
      emit(JournalError('Could not update entry: $e'));
    }
  }
}
