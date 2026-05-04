import '../models/journal_entry.dart';

/// Pure Dart, no dependencies, no API calls.
/// Takes a list of JournalEntry and returns human-readable insight strings.
class InsightEngine {
  final List<JournalEntry> entries;

  const InsightEngine(this.entries);

  /// Main entry point — returns all insights sorted by relevance.
  List<String> generate() {
    if (entries.isEmpty) return [];

    final insights = <String>[];

    final best = _bestDay();
    if (best != null) insights.add(best);

    final worst = _worstDay();
    if (worst != null) insights.add(worst);

    final streak = _consistencyNote();
    if (streak != null) insights.add(streak);

    final trend = _recentTrend();
    if (trend != null) insights.add(trend);

    insights.addAll(_keywordInsights());

    return insights;
  }

  // ── Best day of week ───────────────────────────────────────────────

  String? _bestDay() {
    final byDay = _averageMoodByWeekday();
    if (byDay.isEmpty) return null;

    final best = byDay.entries.reduce((a, b) => a.value > b.value ? a : b);
    // Only report if meaningfully better than average
    final avg = byDay.values.reduce((a, b) => a + b) / byDay.length;
    if (best.value - avg < 0.4) return null;

    return 'You tend to feel best on ${_weekdayName(best.key)}s 🌟';
  }

  // ── Worst day of week ──────────────────────────────────────────────

  String? _worstDay() {
    final byDay = _averageMoodByWeekday();
    if (byDay.isEmpty) return null;

    final worst = byDay.entries.reduce((a, b) => a.value < b.value ? a : b);
    final avg = byDay.values.reduce((a, b) => a + b) / byDay.length;
    if (avg - worst.value < 0.4) return null;

    return '${_weekdayName(worst.key)}s tend to feel harder for you 💙';
  }

  // ── Recent 7-day trend vs previous 7 days ─────────────────────────

  String? _recentTrend() {
    final now = DateTime.now();
    final cutRecent = now.subtract(const Duration(days: 7));
    final cutPrev = now.subtract(const Duration(days: 14));

    final recent = entries
        .where((e) => e.date.isAfter(cutRecent))
        .map((e) => e.moodIndex)
        .toList();

    final previous = entries
        .where((e) => e.date.isAfter(cutPrev) && e.date.isBefore(cutRecent))
        .map((e) => e.moodIndex)
        .toList();

    if (recent.length < 2 || previous.length < 2) return null;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final prevAvg = previous.reduce((a, b) => a + b) / previous.length;
    final delta = recentAvg - prevAvg;

    if (delta > 0.5) return 'Your mood has been improving this week 📈';
    if (delta < -0.5) return 'Your mood dipped a bit this week 📉';
    return 'Your mood has been steady this week ➡️';
  }

  // ── Consistency note ───────────────────────────────────────────────

  String? _consistencyNote() {
    final last14 = entries.where((e) {
      return e.date.isAfter(DateTime.now().subtract(const Duration(days: 14)));
    }).toList();

    if (last14.isEmpty) return null;

    // Count distinct days logged
    final days = last14
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();

    if (days.length >= 10) {
      return 'Great consistency — you\'ve journaled ${days.length} of the last 14 days 🏆';
    }
    if (days.length >= 5) {
      return 'You\'ve journaled ${days.length} of the last 14 days — keep it up 👍';
    }
    return null; // Not enough to comment on
  }

  // ── Keyword impact insights ────────────────────────────────────────

  List<String> _keywordInsights() {
    // keyword → emoji for the insight sentence
    const keywords = {
      'stress': ('stress', '😓'),
      'stressed': ('stress', '😓'),
      'work': ('work', '💼'),
      'tired': ('tiredness', '😴'),
      'exhausted': ('tiredness', '😴'),
      'sleep': ('sleep', '🛌'),
      'slept': ('sleep', '🛌'),
      'exercise': ('exercise', '🏃'),
      'workout': ('exercise', '🏃'),
      'gym': ('exercise', '🏃'),
      'anxious': ('anxiety', '😰'),
      'anxiety': ('anxiety', '😰'),
      'grateful': ('gratitude', '🙏'),
      'thankful': ('gratitude', '🙏'),
    };

    // Group entries by topic (normalized label → list of moodIndex)
    final Map<String, List<int>> topicMoods = {};

    for (final entry in entries) {
      final words = entry.note.toLowerCase().split(RegExp(r'\W+'));
      final matchedTopics = <String>{};

      for (final word in words) {
        final match = keywords[word];
        if (match != null && !matchedTopics.contains(match.$1)) {
          matchedTopics.add(match.$1);
          topicMoods.putIfAbsent(match.$1, () => []).add(entry.moodIndex);
        }
      }
    }

    final insights = <String>[];

    for (final topic in topicMoods.keys) {
      final moods = topicMoods[topic]!;
      if (moods.length < 2) continue; // need at least 2 entries to be meaningful

      final avg = moods.reduce((a, b) => a + b) / moods.length;
      final emoji = keywords.values
          .firstWhere((v) => v.$1 == topic)
          .$2;

      if (avg <= 1.5) {
        insights.add('Entries mentioning $topic tend to be lower mood $emoji');
      } else if (avg >= 3.0) {
        insights.add('Entries mentioning $topic tend to be higher mood $emoji');
      }
    }

    return insights;
  }

  // ── Helpers ────────────────────────────────────────────────────────

  /// Returns weekday (1=Mon … 7=Sun) → average moodIndex,
  /// only for weekdays that have at least 2 entries.
  Map<int, double> _averageMoodByWeekday() {
    final Map<int, List<int>> grouped = {};

    for (final entry in entries) {
      grouped
          .putIfAbsent(entry.date.weekday, () => [])
          .add(entry.moodIndex);
    }

    return Map.fromEntries(
      grouped.entries
          .where((e) => e.value.length >= 2)
          .map((e) {
            final avg = e.value.reduce((a, b) => a + b) / e.value.length;
            return MapEntry(e.key, avg);
          }),
    );
  }

  String _weekdayName(int weekday) {
    const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return names[weekday - 1];
  }
}