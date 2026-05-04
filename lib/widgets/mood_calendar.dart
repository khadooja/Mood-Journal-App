import 'package:gap/gap.dart';
import '../models/mood_option.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/mood_analytics_repository.dart';
import 'package:mindtrack/widgets/entry_detail_screen.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late DateTime _focusedMonth;
  late MoodAnalyticsRepository _repo;
  Map<DateTime, int> _calendarData = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _repo = MoodAnalyticsRepository(Hive.box<JournalEntry>('journalBox'));
    _loadMonth();
  }

  void _loadMonth() {
    setState(() {
      _calendarData = _repo.getMonthCalendar(
        month: _focusedMonth.month,
        year: _focusedMonth.year,
      );
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadMonth();
  }

  void _nextMonth() {
    final now = DateTime.now();
    // Don't allow navigating into the future
    if (_focusedMonth.year == now.year &&
        _focusedMonth.month == now.month) return;
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadMonth();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    return !(_focusedMonth.year == now.year &&
        _focusedMonth.month == now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FCD).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthHeader(),
          const Gap(12),
          _buildWeekdayRow(),
          const Gap(6),
          _buildDayGrid(),
          const Gap(8),
          _buildCalendarLegend(),
        ],
      ),
    );
  }

  // ── Month navigation header ──────────────────────────────────────
  Widget _buildMonthHeader() {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December',
    ];
    final label =
        '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';

    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2B55),
          ),
        ),
        const Spacer(),
        _NavButton(
          icon: Icons.chevron_left_rounded,
          onTap: _previousMonth,
          enabled: true,
        ),
        const Gap(4),
        _NavButton(
          icon: Icons.chevron_right_rounded,
          onTap: _nextMonth,
          enabled: _canGoNext,
        ),
      ],
    );
  }

  // ── Day-of-week labels ───────────────────────────────────────────
  Widget _buildWeekdayRow() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: labels.map((d) {
        return Expanded(
          child: Center(
            child: Text(
              d,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFBBB7DF),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Main grid ────────────────────────────────────────────────────
  Widget _buildDayGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    // Monday = 1, so offset = weekday - 1 (0-indexed Monday start)
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 36));
              }

              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNumber,
              );
              final moodIndex = _calendarData[date];
              final isToday = _isToday(date);
              final isFuture = date.isAfter(DateTime.now());

              return Expanded(
                child: _DayCell(
                  day: dayNumber,
                  moodIndex: moodIndex,
                  isToday: isToday,
                  isFuture: isFuture,
                  onTap: moodIndex != null
                      ? () => _openEntriesForDay(date)
                      : null,
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ── Navigate to the entry for a tapped day ───────────────────────
  void _openEntriesForDay(DateTime date) {
    final entries = _repo.box.values
        .where((e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    if (entries.isEmpty) return;

    // If one entry — go directly; if multiple — show bottom sheet picker
    if (entries.length == 1) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => EntryDetailScreen(entry: entries.first),
      ));
    } else {
      _showDayPicker(entries);
    }
  }

  void _showDayPicker(List<JournalEntry> entries) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E5F5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(16),
            Text(
              '${entries.length} entries this day',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2B55),
              ),
            ),
            const Gap(12),
            ...entries.map((entry) {
              final mood = kMoodOptions[entry.moodIndex];
              final hour = entry.date.hour.toString().padLeft(2, '0');
              final min = entry.date.minute.toString().padLeft(2, '0');
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: mood.lightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      mood.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                title: Text(
                  entry.note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF2D2B55),
                  ),
                ),
                subtitle: Text(
                  '$hour:$min · ${mood.label}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9D95C7),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => EntryDetailScreen(entry: entry),
                  ));
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Bottom legend ────────────────────────────────────────────────
  Widget _buildCalendarLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE8E5F5)),
            shape: BoxShape.circle,
          ),
        ),
        const Gap(4),
        Text(
          'No entry',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFFBBB7DF),
          ),
        ),
        const Gap(16),
        ...kMoodOptions.map((mood) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: mood.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    mood.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF9D95C7),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

// ── Private sub-widgets ──────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final int? moodIndex;
  final bool isToday;
  final bool isFuture;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.moodIndex,
    required this.isToday,
    required this.isFuture,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mood = moodIndex != null ? kMoodOptions[moodIndex!] : null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mood dot
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: mood != null
                    ? mood.color.withValues(alpha: 0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(
                        color: const Color(0xFF7C6FCD),
                        width: 1.5,
                      )
                    : mood == null
                        ? Border.all(
                            color: isFuture
                                ? Colors.transparent
                                : const Color(0xFFE8E5F5),
                          )
                        : null,
              ),
              child: mood != null
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: mood.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const Gap(2),
            // Day number
            Text(
              '$day',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight:
                    isToday ? FontWeight.w700 : FontWeight.w400,
                color: isFuture
                    ? const Color(0xFFE8E5F5)
                    : isToday
                        ? const Color(0xFF7C6FCD)
                        : const Color(0xFF9D95C7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFECEAF8)
              : const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? const Color(0xFF7C6FCD)
              : const Color(0xFFE8E5F5),
        ),
      ),
    );
  }
}