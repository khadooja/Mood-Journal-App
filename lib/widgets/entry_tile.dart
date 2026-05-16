import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';
import 'entry_detail_screen.dart';

/// Mood-derived insight tag — no extra API call.
const List<String> _kAiInsightTags = [
  'Low Energy',  // 0 – Rough
  'Needs Rest',  // 1 – Low
  'Mixed Mood',  // 2 – Okay
  'Positive',    // 3 – Good
  'Energised',   // 4 – Great
];

/// Premium journal entry card with mood avatar, badge, and chevron.
class EntryTile extends StatelessWidget {
  const EntryTile({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final mood       = kMoodOptions[entry.moodIndex];
    final insightTag = _kAiInsightTags[entry.moodIndex];

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EntryDetailScreen(entry: entry),
        ),
      ),
      child: Container(
        decoration: AppDecorations.glassCard(radius: AppRadius.xl),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Mood avatar circle ────────────────────────────
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: mood.lightColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: mood.color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: mood.color.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Hero(
                  tag: 'mood_emoji_${entry.id}',
                  child: Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // ── Content ──────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date + mood label row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(entry.date),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      // Mood label pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: 3,
                        ),
                        decoration: AppDecorations.pill(color: mood.lightColor),
                        child: Text(
                          mood.label,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mood.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Note preview
                  Text(
                    entry.note,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.55,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Emotional insight badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: AppRadius.fullAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 11,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          insightTag,
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
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── Chevron ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}  $h:$m';
  }
}
