import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_spacing.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';

/// Pure logic — picks the single most relevant state message.
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

  static HomeSummaryData resolve({
    required List<JournalEntry> entries,
    required int streak,
  }) {
    final now       = DateTime.now();
    final today     = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    bool same(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final todayEs = entries.where((e) => same(e.date, today)).toList();
    final yestEs  = entries.where((e) => same(e.date, yesterday)).toList();

    // 1. Streak at risk
    if (streak > 1 && todayEs.isEmpty && yestEs.isEmpty) {
      return HomeSummaryData(
        message: "Your $streak-day streak is at risk — write today to keep it!",
        emoji: '🔥',
        color: AppColors.warning,
        lightColor: AppColors.warningLight,
      );
    }

    // 2. No entry today — nudge with yesterday's mood
    if (todayEs.isEmpty) {
      if (yestEs.isNotEmpty) {
        final mood = kMoodOptions[yestEs.last.moodIndex];
        return HomeSummaryData(
          message: "Yesterday you felt ${mood.label}. How are you doing today?",
          emoji: mood.emoji,
          color: mood.color,
          lightColor: mood.lightColor,
        );
      }
      return HomeSummaryData(
        message: "Start your first entry today and begin tracking your mood.",
        emoji: '📝',
        color: AppColors.primary,
        lightColor: AppColors.surfaceVariant,
      );
    }

    // 3. Entry today — show today + weekly avg
    final todayAvgIdx = (todayEs.map((e) => e.moodIndex).reduce((a, b) => a + b) /
            todayEs.length)
        .round()
        .clamp(0, 4);

    final weekCutoff  = today.subtract(const Duration(days: 7));
    final weekEntries = entries.where((e) => e.date.isAfter(weekCutoff)).toList();
    final todayMood   = kMoodOptions[todayAvgIdx];

    if (weekEntries.length >= 3) {
      final weekAvgIdx = (weekEntries.map((e) => e.moodIndex).reduce((a, b) => a + b) /
              weekEntries.length)
          .round()
          .clamp(0, 4);
      final weekMood = kMoodOptions[weekAvgIdx];
      return HomeSummaryData(
        message:
            "You're feeling ${todayMood.label} today. Your week has been ${weekMood.label} on average.",
        emoji: todayMood.emoji,
        color: todayMood.color,
        lightColor: todayMood.lightColor,
      );
    }

    return HomeSummaryData(
      message:
          "You're feeling ${todayMood.label} today. Keep journaling to unlock weekly insights.",
      emoji: todayMood.emoji,
      color: todayMood.color,
      lightColor: todayMood.lightColor,
    );
  }
}

/// Premium Daily Prompt card — gradient background, emoji orb, CTA arrow.
class HomeSummaryCard extends StatelessWidget {
  final List<JournalEntry> entries;
  final int streak;
  final VoidCallback? onTap;

  const HomeSummaryCard({
    super.key,
    required this.entries,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final data = HomeSummaryData.resolve(entries: entries, streak: streak);

    // Choose gradient colors based on mood/state
    final List<Color> gradientColors = _gradientFor(data.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppDecorations.gradientCard(
          colors: gradientColors,
          radius: AppRadius.xl,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Emoji orb with glow
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.20),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  data.emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.message,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap to write your thoughts today',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Arrow CTA
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: data.color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: data.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _gradientFor(Color accent) {
    // Map mood accent to harmonious gradient pairs
    final hsl = HSLColor.fromColor(accent);
    final start = hsl
        .withSaturation((hsl.saturation * 0.4).clamp(0.0, 1.0))
        .withLightness(0.92)
        .toColor();
    final end = hsl
        .withSaturation((hsl.saturation * 0.55).clamp(0.0, 1.0))
        .withLightness(0.86)
        .toColor();
    return [start, end];
  }
}