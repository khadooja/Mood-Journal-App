import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';

/// 4-up pastel stat cards shown on the HomeScreen dashboard.
/// Derives all values from [entries] and [streak] — no cubit/repository calls.
class HomeStatCards extends StatelessWidget {
  final List<JournalEntry> entries;
  final int streak;

  const HomeStatCards({
    super.key,
    required this.entries,
    required this.streak,
  });

  // ── Value derivation (pure, UI-layer only) ─────────────────────────────

  String get _moodToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayEntries = entries.where((e) {
      final d = e.date;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    if (todayEntries.isEmpty) return '—';
    final avgIdx =
        (todayEntries.map((e) => e.moodIndex).reduce((a, b) => a + b) /
                todayEntries.length)
            .round()
            .clamp(0, 4);
    return kMoodOptions[avgIdx].emoji;
  }

  int get _entriesThisWeek {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    return entries.where((e) => !e.date.isBefore(monday)).length;
  }

  int get _longestStreak {
    if (entries.isEmpty) return 0;
    final sorted = [...entries]..sort((a, b) => a.date.compareTo(b.date));

    DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

    int longest = 1;
    int current = 1;
    DateTime? prev = dateOnly(sorted.first.date);

    for (int i = 1; i < sorted.length; i++) {
      final day = dateOnly(sorted[i].date);
      if (day == prev) continue;
      if (day.difference(prev!).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
      prev = day;
    }
    return longest;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _StatCard(
          label: 'Mood Today',
          value: _moodToday,
          isEmoji: true,
          bg: AppColors.statMoodBg,
          iconColor: AppColors.statMoodIcon,
          icon: Icons.mood_rounded,
        ),
        _StatCard(
          label: 'This Week',
          value: '$_entriesThisWeek',
          unit: _entriesThisWeek == 1 ? 'entry' : 'entries',
          bg: AppColors.statEntriesBg,
          iconColor: AppColors.statEntriesIcon,
          icon: Icons.edit_note_rounded,
        ),
        _StatCard(
          label: 'Current Streak',
          value: '$streak',
          unit: streak == 1 ? 'day' : 'days',
          bg: AppColors.statStreakBg,
          iconColor: AppColors.statStreakIcon,
          icon: Icons.local_fire_department_rounded,
        ),
        _StatCard(
          label: 'Longest Streak',
          value: '$_longestStreak',
          unit: _longestStreak == 1 ? 'day' : 'days',
          bg: AppColors.statLongestBg,
          iconColor: AppColors.statLongestIcon,
          icon: Icons.emoji_events_rounded,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final bool isEmoji;
  final Color bg;
  final Color iconColor;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    this.unit,
    this.isEmoji = false,
    required this.bg,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Value
          if (isEmoji)
            Text(value, style: const TextStyle(fontSize: 24))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      unit!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          // Label
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
