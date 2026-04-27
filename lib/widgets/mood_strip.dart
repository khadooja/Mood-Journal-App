import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';

/// A 7-day mood overview strip.
///
/// Reads real entry data from [JournalCubit].
/// Falls back to the same empty placeholder UI when no entry exists for a day.
/// Design is pixel-identical to the original static version.
class MoodStrip extends StatelessWidget {
  const MoodStrip({super.key});

  // ────────────────────────────────────────────────
  // Build a map of { dateOnly → latest JournalEntry }
  // covering the past 7 calendar days (today = index 6-based on weekday).
  // ────────────────────────────────────────────────
  Map<int, JournalEntry> _buildWeekMap(List<JournalEntry> entries) {
    final now = DateTime.now();
    // weekday: Monday=1 … Sunday=7  →  strip index 0…6
    final todayIndex = now.weekday - 1; // 0-based index in the M-T-W-T-F-S-S row

    // Compute the Monday of the current week
    final monday = DateTime(now.year, now.month, now.day - todayIndex);

    // Map: strip index (0‒6) → latest entry on that day
    final Map<int, JournalEntry> weekMap = {};

    for (final entry in entries) {
      final d = entry.date;
      final dayStart = DateTime(monday.year, monday.month, monday.day);

      final diff = DateTime(d.year, d.month, d.day)
          .difference(dayStart)
          .inDays;

      // Only include days within this week (0 = Monday … 6 = Sunday)
      if (diff < 0 || diff > 6) continue;

      // Keep the latest entry per day
      if (!weekMap.containsKey(diff) ||
          entry.date.isAfter(weekMap[diff]!.date)) {
        weekMap[diff] = entry;
      }
    }

    return weekMap;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalCubit, JournalState>(
      builder: (context, state) {
        final Map<int, JournalEntry> weekMap =
            state is JournalLoaded ? _buildWeekMap(state.entries) : {};

        return _StripView(weekMap: weekMap);
      },
    );
  }
}

// ────────────────────────────────────────────────
// Pure rendering widget — keeps build() clean.
// ────────────────────────────────────────────────
class _StripView extends StatelessWidget {
  const _StripView({required this.weekMap});

  final Map<int, JournalEntry> weekMap;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FCD).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9D95C7),
              letterSpacing: 0.5,
            ),
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final isToday = index == DateTime.now().weekday - 1;
              final entry   = weekMap[index];
              final hasMood = entry != null;
              final mood    = hasMood ? kMoodOptions[entry!.moodIndex] : null;

              return Column(
                children: [
                  // Day letter
                  Text(
                    days[index],
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? const Color(0xFF7C6FCD)
                          : const Color(0xFFBBB7DF),
                    ),
                  ),
                  const Gap(8),
                  // Day circle
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isToday
                          ? const Color(0xFF7C6FCD).withValues(alpha: 0.12)
                          : const Color(0xFFF0EEF9),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: const Color(0xFF7C6FCD),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: hasMood
                          ? Text(
                              mood!.emoji,
                              style: const TextStyle(fontSize: 14),
                            )
                          : const Icon(
                              Icons.add,
                              size: 14,
                              color: Color(0xFFBBB7DF),
                            ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
