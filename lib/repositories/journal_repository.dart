import '../models/journal_entry.dart';
import '../storage/journal_storage.dart';

/// Single access point for all journal data operations.
/// UI and (future) Cubit go through here — never touch JournalStorage directly.
class JournalRepository {
  final JournalStorage _storage;

  JournalRepository({JournalStorage? storage})
      : _storage = storage ?? JournalStorage();

  /// Returns all entries, newest first.
  Future<List<JournalEntry>> loadEntries() async {
    final entries = await _storage.getAllEntries();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Persists a new entry.
  Future<void> addEntry(JournalEntry entry) async {
    await _storage.saveEntry(entry);
  }

  /// Removes an entry by its id.
  Future<void> deleteEntry(String id) async {
    await _storage.deleteEntry(id);
  }
}