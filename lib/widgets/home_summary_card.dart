import 'package:gap/gap.dart';
import '../models/mood_option.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Pure logic class — picks the single most relevant message
/// to show the user based on their current data state.
class HomeSummaryData {
  final String message;
  final String emoji;
  final Color color;
  final Color lightColor;

  const HomeSummaryData({
    required this.message,
    required this.emoji,
    required this.color,
    required this.lightColor,
  });

  /// Priority order:
  /// 1. Streak at risk (no entry today AND no entry yesterday)
  /// 2. No entry today — reference yesterday's mood
  /// 3. Entry exists today — show today's mood + weekly average
  /// 4. Fallback (first-ever use)
  static HomeSummaryData resolve({
    required List<JournalEntry> entries,
    required int streak,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final todayEntries =
        entries.where((e) => isSameDay(e.date, today)).toList();
    final yesterdayEntries =
        entries.where((e) => isSameDay(e.date, yesterday)).toList();

    // ── 1. Streak at risk ──────────────────────────────
    if (streak > 1 && todayEntries.isEmpty && yesterdayEntries.isEmpty) {
      return HomeSummaryData(
        message: "Your $streak-day streak is at risk — write today to keep it!",
        emoji: '🔥',
        color: const Color(0xFFFFB830),
        lightColor: const Color(0xFFFFF6E0),
      );
    }

    // ── 2. No entry today — nudge with yesterday's mood ─
    if (todayEntries.isEmpty) {
      if (yesterdayEntries.isNotEmpty) {
        final mood = kMoodOptions[yesterdayEntries.last.moodIndex];
        return HomeSummaryData(
          message: "Yesterday you felt ${mood.label}. How are you doing today?",
          emoji: mood.emoji,
          color: mood.color,
          lightColor: mood.lightColor,
        );
      }
      // No recent entries at all
      return HomeSummaryData(
        message: "Start your first entry today and begin tracking your mood.",
        emoji: '📝',
        color: const Color(0xFF7C6FCD),
        lightColor: const Color(0xFFECEAF8),
      );
    }

    // ── 3. Entry exists today — show today + weekly avg ─
    final todayAvgIndex = (todayEntries
                .map((e) => e.moodIndex)
                .reduce((a, b) => a + b) /
            todayEntries.length)
        .round()
        .clamp(0, 4);

    final weekCutoff = today.subtract(const Duration(days: 7));
    final weekEntries =
        entries.where((e) => e.date.isAfter(weekCutoff)).toList();

    final todayMood = kMoodOptions[todayAvgIndex];

    if (weekEntries.length >= 3) {
      final weekAvgIndex = (weekEntries
                  .map((e) => e.moodIndex)
                  .reduce((a, b) => a + b) /
              weekEntries.length)
          .round()
          .clamp(0, 4);
      final weekMood = kMoodOptions[weekAvgIndex];
      return HomeSummaryData(
        message:
            "You're feeling ${todayMood.label} today. Your week has been ${weekMood.label} on average.",
        emoji: todayMood.emoji,
        color: todayMood.color,
        lightColor: todayMood.lightColor,
      );
    }

    // Today entry exists but not enough week data yet
    return HomeSummaryData(
      message: "You're feeling ${todayMood.label} today. Keep journaling to unlock weekly insights.",
      emoji: todayMood.emoji,
      color: todayMood.color,
      lightColor: todayMood.lightColor,
    );
  }
}

/// The card widget itself — stateless, takes resolved data.
class HomeSummaryCard extends StatelessWidget {
  final List<JournalEntry> entries;
  final int streak;

  const HomeSummaryCard({
    super.key,
    required this.entries,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final data = HomeSummaryData.resolve(
      entries: entries,
      streak: streak,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: data.lightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.color.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Emoji bubble
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const Gap(14),
          // Message
          Expanded(
            child: Text(
              data.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2D2B55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}