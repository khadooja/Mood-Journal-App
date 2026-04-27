import 'package:mindtrack/models/journal_entry.dart';
import 'package:mindtrack/storage/journal_storage.dart';

class JournalRepository {
  Future<List<JournalEntry>> loadEntries() async {
    return JournalStorage.getAll();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await JournalStorage.save(entry);
  }

  Future<void> deleteEntry(String id) async {
    await JournalStorage.delete(id);
  }
}