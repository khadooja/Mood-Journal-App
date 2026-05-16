import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';

/// Premium 7-day mood overview strip — reads live data from [JournalCubit].
class MoodStrip extends StatelessWidget {
  const MoodStrip({super.key});

  Map<int, JournalEntry> _buildWeekMap(List<JournalEntry> entries) {
    final now        = DateTime.now();
    final todayIndex = now.weekday - 1;
    final monday     = DateTime(now.year, now.month, now.day - todayIndex);
    final Map<int, JournalEntry> weekMap = {};

    for (final entry in entries) {
      final d    = entry.date;
      final diff = DateTime(d.year, d.month, d.day)
          .difference(DateTime(monday.year, monday.month, monday.day))
          .inDays;
      if (diff < 0 || diff > 6) continue;
      if (!weekMap.containsKey(diff) || entry.date.isAfter(weekMap[diff]!.date)) {
        weekMap[diff] = entry;
      }
    }
    return weekMap;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        final weekMap =
            state is JournalLoaded ? _buildWeekMap(state.entries) : <int, JournalEntry>{};
        return _StripView(weekMap: weekMap);
      },
    );
  }
}

class _StripView extends StatelessWidget {
  const _StripView({required this.weekMap});

  final Map<int, JournalEntry> weekMap;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      decoration: AppDecorations.glassCard(radius: AppRadius.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This Week',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your mood journey',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              // Analytics shortcut pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.fullAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Analytics',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Day circles row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday   = index == todayIndex;
              final isFuture  = index > todayIndex;
              final entry     = weekMap[index];
              final hasMood   = entry != null;
              final mood      = hasMood ? kMoodOptions[entry.moodIndex] : null;

              return _DayCircle(
                dayLabel: days[index],
                isToday: isToday,
                isFuture: isFuture,
                hasMood: hasMood,
                mood: mood,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  final String dayLabel;
  final bool isToday;
  final bool isFuture;
  final bool hasMood;
  final MoodOption? mood;

  const _DayCircle({
    required this.dayLabel,
    required this.isToday,
    required this.isFuture,
    required this.hasMood,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Day label
        Text(
          dayLabel,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isToday ? AppColors.primary : AppColors.textHint,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Circle
        _buildCircle(),
      ],
    );
  }

  Widget _buildCircle() {
    if (isToday) {
      // Today: gradient ring
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasMood
              ? LinearGradient(
                  colors: [mood!.color, mood!.color.withValues(alpha: 0.70)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDeep],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: hasMood
              ? Text(mood!.emoji, style: const TextStyle(fontSize: 18))
              : const Icon(Icons.add_rounded, size: 18, color: Colors.white),
        ),
      );
    }

    if (hasMood) {
      // Past day with mood: soft pastel circle + emoji + checkmark
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: mood!.lightColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: mood!.color.withValues(alpha: 0.30),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(mood!.emoji, style: const TextStyle(fontSize: 17)),
            ),
          ),
          // Tiny checkmark overlay bottom-right
          Positioned(
            bottom: -2,
            right: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: mood!.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 9,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (isFuture) {
      // Future: subtle dot placeholder
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.textHint,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Past day, no mood logged
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: const Center(
        child: Icon(Icons.remove_rounded, size: 14, color: AppColors.textHint),
      ),
    );
  }
}
