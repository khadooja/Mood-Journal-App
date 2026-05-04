import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has ever saved their first entry.
/// Single responsibility — one key, two methods.
class FirstEntryService {
  static const String _key = 'has_saved_first_entry';

  /// Returns true if this is the very first entry ever saved.
  static Future<bool> isFirstEntry() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  /// Call immediately after confirming first entry saved.
  static Future<void> markFirstEntrySaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}