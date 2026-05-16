import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../models/mood_option.dart';

class JournalSearchBar extends StatefulWidget {
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int?> onMoodChanged;

  const JournalSearchBar({
    super.key,
    required this.onTextChanged,
    required this.onMoodChanged,
  });

  @override
  State<JournalSearchBar> createState() => _JournalSearchBarState();
}

class _JournalSearchBarState extends State<JournalSearchBar> {
  final TextEditingController _controller = TextEditingController();
  int? _selectedMood;
  bool _hasFocus = false;
  bool _showFilter = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectMood(int index) {
    setState(() => _selectedMood = _selectedMood == index ? null : index);
    widget.onMoodChanged(_selectedMood);
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _selectedMood = null;
      _showFilter = false;
    });
    widget.onTextChanged('');
    widget.onMoodChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = _controller.text.isNotEmpty || _selectedMood != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Premium pill search field ────────────────────────
        Focus(
          onFocusChange: (v) => setState(() => _hasFocus = v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: AppDecorations.searchField(focused: _hasFocus),
            child: Row(
              children: [
                // Search icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: _hasFocus ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                // Text field
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onTextChanged,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Search your entries…',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textHint,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Clear button
                if (hasFilter)
                  GestureDetector(
                    onTap: _clear,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                // Filter toggle button
                GestureDetector(
                  onTap: () => setState(() => _showFilter = !_showFilter),
                  child: Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _showFilter
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: _showFilter ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Mood filter pills (collapsible) ──────────────────
        AnimatedCrossFade(
          firstChild: const SizedBox(height: 0, width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(kMoodOptions.length, (i) {
                  final mood       = kMoodOptions[i];
                  final isSelected = _selectedMood == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => _selectMood(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? mood.lightColor : AppColors.surface,
                          borderRadius: AppRadius.fullAll,
                          border: Border.all(
                            color: isSelected
                                ? mood.color
                                : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: mood.color.withValues(alpha: 0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              mood.label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? mood.color
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          crossFadeState: _showFilter
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
      ],
    );
  }
}