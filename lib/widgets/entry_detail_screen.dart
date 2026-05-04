import 'package:gap/gap.dart';
import '../models/mood_option.dart';
import '../cubit/journal_cubit.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _editMoodIndex = widget.entry.moodIndex;
    _noteController = TextEditingController(text: widget.entry.note);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => _noteController.text.trim().isNotEmpty;

  MoodOption get _currentMood => kMoodOptions[_editMoodIndex];

  // ── Save edited entry ──────────────────────────────────────────────
  Future<void> _saveEdit() async {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();

    final updated = JournalEntry(
      id: widget.entry.id, // same id — overwrites in Hive
      moodIndex: _editMoodIndex,
      note: _noteController.text.trim(),
      date: widget.entry.date, // preserve original date
    );

    await context.read<JournalCubit>().updateEntry(updated);

    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Entry updated',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: _currentMood.color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ── Delete with confirmation ───────────────────────────────────────
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete entry?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2B55),
          ),
        ),
        content: Text(
          'This cannot be undone.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF9D95C7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: const Color(0xFF9D95C7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRow(),
                    const Gap(24),
                    _buildMoodSection(),
                    const Gap(24),
                    _buildNoteSection(),
                    if (_isEditing) ...[const Gap(16), _buildSaveButton()],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: const Color(0xFF2D2B55),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              _isEditing ? 'Edit Entry' : 'Entry',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2B55),
              ),
            ),
          ),
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: const Color(0xFF7C6FCD),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20),
              color: Colors.redAccent,
              onPressed: _confirmDelete,
              tooltip: 'Delete',
            ),
          ] else ...[
            TextButton(
              onPressed: () {
                // Reset to original values on cancel
                setState(() {
                  _isEditing = false;
                  _editMoodIndex = widget.entry.moodIndex;
                  _noteController.text = widget.entry.note;
                });
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF9D95C7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Date row ───────────────────────────────────────────────────────
  Widget _buildDateRow() {
    final date = widget.entry.date;
    const months = [
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
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final label =
        '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day} · $hour:$minute';

    return Row(
      children: [
        const Icon(
          Icons.calendar_today_rounded,
          size: 14,
          color: Color(0xFF9D95C7),
        ),
        const Gap(6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF9D95C7),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ── Mood section ───────────────────────────────────────────────────
  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9D95C7),
          ),
        ),
        const Gap(10),
        _isEditing ? _buildMoodPicker() : _buildMoodBadge(),
      ],
    );
  }

  Widget _buildMoodBadge() {
    final mood = kMoodOptions[widget.entry.moodIndex];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: mood.lightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AFTER
          Hero(
            tag: 'mood_emoji_${widget.entry.id}',
            child: Text(mood.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const Gap(8),
          Text(
            mood.label,
            style: GoogleFonts.inter(
              fontSize: 15,
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
        final mood = kMoodOptions[i];
        final isSelected = _editMoodIndex == i;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _editMoodIndex = i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? mood.lightColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? mood.color : const Color(0xFFE8E5F5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mood.emoji, style: const TextStyle(fontSize: 22)),
                  const Gap(4),
                  Text(
                    mood.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? mood.color : const Color(0xFF9D95C7),
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

  // ── Note section ───────────────────────────────────────────────────
  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Note',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9D95C7),
              ),
            ),
            if (_isEditing)
              Text(
                '${_noteController.text.length} / $_maxChars',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFBBB7DF),
                ),
              ),
          ],
        ),
        const Gap(10),
        _isEditing ? _buildNoteEditor() : _buildNoteReadView(),
      ],
    );
  }

  Widget _buildNoteReadView() {
    return Text(
      widget.entry.note,
      style: GoogleFonts.inter(
        fontSize: 15,
        height: 1.7,
        color: const Color(0xFF2D2B55),
      ),
    );
  }

  Widget _buildNoteEditor() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C6FCD)),
      ),
      child: TextField(
        controller: _noteController,
        maxLines: null,
        maxLength: _maxChars,
        onChanged: (_) => setState(() {}),
        buildCounter:
            (_, {required currentLength, required isFocused, maxLength}) =>
                null,
        style: GoogleFonts.inter(
          fontSize: 15,
          height: 1.7,
          color: const Color(0xFF2D2B55),
        ),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ── Save button (edit mode only) ───────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _canSave ? _saveEdit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentMood.color,
          disabledBackgroundColor: const Color(0xFFE8E5F5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Changes',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
