import '../models/journal_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mindtrack/repositories/insight_engine.dart';

// Add this simple data class at the top of the file
class MoodDataPoint {
  final DateTime date;
  final double moodIndex;
  // Add this getter inside MoodAnalyticsRepository
 
  const MoodDataPoint({required this.date, required this.moodIndex});
}

class MoodAnalyticsRepository {
  final Box<JournalEntry> _box;
  Box<JournalEntry> get box => _box;

  MoodAnalyticsRepository(this._box);

  int getStreak() {
    if (_box.isEmpty) return 0;

    final entries = _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    final today = dateOnly(DateTime.now());
    final mostRecentDay = dateOnly(entries.first.date);

    // Streak is broken if last entry was 2+ days ago
    if (today.difference(mostRecentDay).inDays > 1) return 0;

    int streak = 0;
    DateTime? lastDay;

    for (final entry in entries) {
      final day = dateOnly(entry.date);

      if (lastDay == null) {
        streak = 1;
        lastDay = day;
      } else if (day == lastDay) {
        continue; // multiple entries same day — skip
      } else if (lastDay.difference(day).inDays == 1) {
        streak++;
        lastDay = day;
      } else {
        break; // gap found
      }
    }

    return streak;
  }

  /// Returns one data point per day for the last [days] days.
  /// Days with no entry are filled with -1 (used to show gaps in the chart).
  List<MoodDataPoint> getMoodTrend({int days = 7}) {
    final now = DateTime.now();
    DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    // Build a map of date → average moodIndex for that day
    final Map<DateTime, List<int>> byDay = {};
    for (final entry in _box.values) {
      final day = dateOnly(entry.date);
      byDay.putIfAbsent(day, () => []).add(entry.moodIndex);
    }

    // Generate one point per day for the range
    return List.generate(days, (i) {
      final day = dateOnly(now.subtract(Duration(days: days - 1 - i)));
      final scores = byDay[day];
      final avg = scores != null
          ? scores.reduce((a, b) => a + b) / scores.length
          : -1.0; // -1 = no entry that day
      return MoodDataPoint(date: day, moodIndex: avg);
    });
  }

  List<String> getInsights() {
    final entries = _box.values.toList();
    return InsightEngine(entries).generate();
  }
  /// Returns a map of date → average moodIndex for every day
/// in the given [month] and [year].
/// Days with no entry are absent from the map.
Map<DateTime, int> getMonthCalendar({required int month, required int year}) {
  final Map<DateTime, List<int>> byDay = {};

  for (final entry in _box.values) {
    if (entry.date.month != month || entry.date.year != year) continue;
    final day = DateTime(entry.date.year, entry.date.month, entry.date.day);
    byDay.putIfAbsent(day, () => []).add(entry.moodIndex);
  }

  return byDay.map((day, scores) {
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    return MapEntry(day, avg.round().clamp(0, 4));
  });
}
}
