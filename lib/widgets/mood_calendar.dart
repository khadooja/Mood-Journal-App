import '../models/mood_option.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/mood_analytics_repository.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late final MoodAnalyticsRepository _repo;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _repo = MoodAnalyticsRepository(Hive.box<JournalEntry>('journal_entries'));
  }

  // ── Navigation ───────────────────────────────────────────────────────────

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1));
  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1);
    if (!next.isAfter(DateTime.now())) setState(() => _month = next);
  }

  bool get _canGoForward {
    final now = DateTime.now();
    return _month.year < now.year ||
        (_month.year == now.year && _month.month < now.month);
  }

  // ── Data helpers ─────────────────────────────────────────────────────────

  /// Returns a map of day-of-month → mood index for the current month.
  Map<int, int> _buildDayMap() {
    final raw = _repo.getMonthCalendar(month: _month.month, year: _month.year);
    return {for (final e in raw.entries) e.key.day: e.value};
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _month.year == now.year &&
        _month.month == now.month &&
        day == now.day;
  }

  bool _isFuture(int day) {
    final now = DateTime.now();
    final d = DateTime(_month.year, _month.month, day);
    return d.isAfter(DateTime(now.year, now.month, now.day));
  }

  void _onDayTap(BuildContext context, int day, int? moodIndex) {
    // Without full entry objects (only aggregated moodIndex available),
    // we have nothing to navigate to from the calendar view directly.
    // This is a no-op for now by design — full entry navigation is via EntryTile.
  }

  // Day-sheet not needed since we only have aggregated mood data from getMonthCalendar.
  // Left as a stub for future expansion.

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dayMap = _buildDayMap();
    final firstDay = _month.weekday - 1; // 0=Mon
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: true,
                onTap: _prevMonth,
              ),
              Expanded(
                child: Text(
                  '${monthNames[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.sectionLabel,
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: _canGoForward,
                onTap: _nextMonth,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Day-of-week headers ──────────────────────────────
          Row(
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Grid ─────────────────────────────────────────────
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
            ),
            itemCount: firstDay + daysInMonth,
            itemBuilder: (ctx, i) {
              if (i < firstDay) return const SizedBox.shrink();
              final day = i - firstDay + 1;
              final moodIndex = dayMap[day];
              final hasMood = moodIndex != null;
              final today = _isToday(day);
              final future = _isFuture(day);
              final mood = hasMood ? kMoodOptions[moodIndex] : null;

              return GestureDetector(
                onTap: () => _onDayTap(context, day, moodIndex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  decoration: BoxDecoration(
                    color: hasMood
                        ? mood!.lightColor
                        : today
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: today
                        ? Border.all(color: AppColors.primary, width: 2)
                        : hasMood
                        ? Border.all(color: mood!.color.withValues(alpha: 0.30))
                        : null,
                  ),
                  child: Center(
                    child: hasMood
                        ? Text(
                            mood!.emoji,
                            style: const TextStyle(fontSize: 14),
                          )
                        : Text(
                            '$day',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: today
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: future
                                  ? AppColors.borderLight
                                  : today
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Legend ──────────────────────────────────────────
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.xs,
            children: [
              _LegendItem(
                dot: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    shape: BoxShape.circle,
                  ),
                ),
                label: 'No entry',
              ),
              ...kMoodOptions.map(
                (m) => _LegendItem(
                  dot: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: m.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: m.label,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small reusable sub-widgets ────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceVariant : AppColors.background,
          borderRadius: AppRadius.xsAll,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.primary : AppColors.borderLight,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Widget dot;
  final String label;
  const _LegendItem({required this.dot, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }
}
