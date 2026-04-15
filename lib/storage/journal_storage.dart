import 'package:hive_flutter/hive_flutter.dart';
import '../models/journal_entry.dart';

/// Simple static wrapper around the Hive box for journal entries.
///
/// Kept intentionally flat — no repository pattern yet.
/// Future: replace this with a proper Repository + Datasource layer
/// when Clean Architecture is introduced (cleanly swappable by design).
class JournalStorage {
  static const String _boxName = 'journal_entries';

  static Box<JournalEntry> get _box => Hive.box<JournalEntry>(_boxName);

  /// Opens the Hive box. Must be called once in main() after Hive.initFlutter().
  static Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<JournalEntry>(_boxName);
    }
  }

  /// Returns all entries sorted newest-first.
  static List<JournalEntry> getAll() {
    final entries = _box.values.toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Saves a new entry. Uses the entry's id as the Hive key.
  static Future<void> save(JournalEntry entry) async {
    await _box.put(entry.id, entry);
  }

  /// Deletes an entry by its id.
  static Future<void> delete(String id) async {
    await _box.delete(id);
  }
}
