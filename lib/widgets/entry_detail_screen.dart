import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_decorations.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/app_button.dart';
import '../core/widgets/app_text_field.dart';
import '../cubit/journal_cubit.dart';
import '../models/journal_entry.dart';
import '../models/mood_option.dart';

class EntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;
  const EntryDetailScreen({super.key, required this.entry});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  bool _isEditing = false;
  late int _editMoodIndex;
  late TextEditingController _noteController;

  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _editMoodIndex  = widget.entry.moodIndex;
    _noteController = TextEditingController(text: widget.entry.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => _noteController.text.trim().isNotEmpty;
  MoodOption get _currentMood => kMoodOptions[_editMoodIndex];

  // ── Save edit ──────────────────────────────────────────────────────────

  Future<void> _saveEdit() async {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    final updated = JournalEntry(
      id: widget.entry.id,
      moodIndex: _editMoodIndex,
      note: _noteController.text.trim(),
      date: widget.entry.date,
    );
    await context.read<JournalCubit>().updateEntry(updated);
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entry updated'),
          backgroundColor: _currentMood.color,
        ),
      );
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.errorAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<JournalCubit>().deleteEntry(widget.entry.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, AppSpacing.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRow(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildMoodSection(),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildNoteSection(),
                    if (_isEditing) ...[
                      const SizedBox(height: AppSpacing.lg),
                      AppButton.primary(
                        label: 'Save Changes',
                        onPressed: _canSave ? _saveEdit : null,
                        backgroundColor: _currentMood.color,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Entry' : 'Entry',
              style: AppTextStyles.title,
            ),
          ),
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: AppColors.primary,
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: AppColors.errorAccent,
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
          ] else
            TextButton(
              onPressed: () => setState(() {
                _isEditing    = false;
                _editMoodIndex = widget.entry.moodIndex;
                _noteController.text = widget.entry.note;
              }),
              child: Text(
                'Cancel',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Date ───────────────────────────────────────────────────────────────

  Widget _buildDateRow() {
    final d = widget.entry.date;
    const months   = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    const weekdays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final h   = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return Row(
      children: [
        Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day} · $h:$min',
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  // ── Mood section ───────────────────────────────────────────────────────

  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mood', style: AppTextStyles.caption),
        const SizedBox(height: AppSpacing.sm),
        _isEditing ? _buildMoodPicker() : _buildMoodBadge(),
      ],
    );
  }

  Widget _buildMoodBadge() {
    final mood = kMoodOptions[widget.entry.moodIndex];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: AppDecorations.pill(color: mood.lightColor),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'mood_emoji_${widget.entry.id}',
            child: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            mood.label,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: mood.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodPicker() {
    return Row(
      children: List.generate(kMoodOptions.length, (i) {
        final mood       = kMoodOptions[i];
        final isSelected = _editMoodIndex == i;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _editMoodIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? mood.lightColor : AppColors.surface,
                borderRadius: AppRadius.smAll,
                border: Border.all(
                  color: isSelected ? mood.color : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    mood.label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? mood.color : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Note section ───────────────────────────────────────────────────────

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Note', style: AppTextStyles.caption),
            if (_isEditing)
              Text(
                '${_noteController.text.length} / $_maxChars',
                style: AppTextStyles.labelMedium,
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _isEditing ? _buildNoteEditor() : _buildNoteReadView(),
      ],
    );
  }

  Widget _buildNoteReadView() {
    return Text(
      widget.entry.note,
      style: AppTextStyles.bodyLarge,
    );
  }

  Widget _buildNoteEditor() {
    return AppTextField(
      controller: _noteController,
      maxLines: null,
      maxLength: _maxChars,
      onChanged: (_) => setState(() {}),
    );
  }
}
