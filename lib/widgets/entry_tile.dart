import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/journal_entry.dart';
import '../models/mood_option.dart';

/// Maps moodIndex → a short AI insight tag label.
/// Derived purely from the stored moodIndex — NO extra API call.
const List<String> _kAiInsightTags = [
  'Low Energy',   // 0 – Rough
  'Needs Rest',   // 1 – Low
  'Mixed Mood',   // 2 – Okay
  'Positive',     // 3 – Good
  'Energised',    // 4 – Great
];

/// A reusable card widget that displays a single [JournalEntry].
///
/// Uses [entry.moodIndex] to look up the matching [MoodOption] from
/// [kMoodOptions] for the emoji, label, and color values.
/// Visual design is intentionally unchanged from the original HomeScreen card.
///
/// PHASE 3: Shows a small AI insight tag below the note, derived from
/// moodIndex — no extra API call needed.
class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry});

  final JournalEntry entry;

  // ────────────────────────────────────────────────
  // Date formatter — short form: "Mon, Apr 26  17:24"
  // ────────────────────────────────────────────────
  String _formatEntryDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour   = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final mood       = kMoodOptions[entry.moodIndex];
    final insightTag = _kAiInsightTags[entry.moodIndex];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6FCD).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: mood badge + date ──────────────────
              Row(
                children: [
                  // Mood badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: mood.lightColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 14)),
                        const Gap(5),
                        Text(
                          mood.label,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: mood.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Date
                  Text(
                    _formatEntryDate(entry.date),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF9D95C7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const Gap(12),
              // ── Note text ───────────────────────────────────
              Text(
                entry.note,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.6,
                  color: const Color(0xFF2D2B55),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(10),
              // ── PHASE 3: AI insight tag ─────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C6FCD).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 10,
                          color: Color(0xFF7C6FCD),
                        ),
                        const Gap(4),
                        Text(
                          insightTag,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7C6FCD),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
