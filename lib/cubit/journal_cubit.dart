import 'journal_state.dart';
import '../models/journal_entry.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/journal_repository.dart';

/// Owns all business logic for the journal feature.
/// Screens will call these methods — never the repository directly.
class JournalCubit extends Cubit<JournalState> {
  final JournalRepository _repository;

  JournalCubit({required JournalRepository repository})
      : _repository = repository,
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
}