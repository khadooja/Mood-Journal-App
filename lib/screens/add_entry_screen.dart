import 'package:gap/gap.dart';
import '../cubit/journal_cubit.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';


// ─────────────────────────────────────────────────────────
// Mood model — pure data, no architecture layer needed yet
// ─────────────────────────────────────────────────────────
class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final Color lightColor;

  const MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.lightColor,
  });
}

const List<MoodOption> kMoodOptions = [
  MoodOption(
    emoji: '😢',
    label: 'Rough',
    color: Color(0xFF5B8DEF),
    lightColor: Color(0xFFEAF0FD),
  ),
  MoodOption(
    emoji: '😟',
    label: 'Low',
    color: Color(0xFF9B6FDB),
    lightColor: Color(0xFFF2ECFB),
  ),
  MoodOption(
    emoji: '😐',
    label: 'Okay',
    color: Color(0xFF7A8FA6),
    lightColor: Color(0xFFEDF1F5),
  ),
  MoodOption(
    emoji: '😊',
    label: 'Good',
    color: Color(0xFF4CAF82),
    lightColor: Color(0xFFE8F7F0),
  ),
  MoodOption(
    emoji: '😄',
    label: 'Great',
    color: Color(0xFFFFB830),
    lightColor: Color(0xFFFFF6E0),
  ),
];

// ─────────────────────────────────────────────────────────
// Add Entry Screen
// ─────────────────────────────────────────────────────────
class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();
  late AnimationController _moodAnimController;
  late Animation<double> _moodScaleAnim;

  static const int _maxChars = 500;

  @override
  void initState() {
    super.initState();
    _moodAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _moodScaleAnim = CurvedAnimation(
      parent: _moodAnimController,
      curve: Curves.elasticOut,
    );
    _noteController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _moodAnimController.dispose();
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  // ── Derived state ───────────────────────────────────────
  bool get _canSave =>
      _selectedMoodIndex != null && _noteController.text.trim().isNotEmpty;

  MoodOption? get _selectedMood =>
      _selectedMoodIndex != null ? kMoodOptions[_selectedMoodIndex!] : null;

  // ── Mood selection ──────────────────────────────────────
  void _selectMood(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMoodIndex = index);
    _moodAnimController.forward(from: 0);
  }

  // ── Save entry ──────────────────────────────────────────
  void _saveEntry() {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    _noteFocusNode.unfocus();

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _noteController.text.trim(),
      mood: _selectedMood!.label,
      date: DateTime.now(),
      moodIndex: ,
        note: '',
    );

    context.read<JournalCubit>().addEntry(entry);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              _selectedMood!.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const Gap(10),
            Text(
              'Entry saved!',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: _selectedMood!.color,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.of(context).pop();
    });
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(8),
                    _buildDateBadge(),
                    const Gap(28),
                    _buildMoodSection(),
                    const Gap(28),
                    _buildNoteSection(),
                    const Gap(24),
                    _buildSaveButton(),
                    const Gap(20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // App Bar
  // ─────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
            ),
            color: const Color(0xFF2D2B55),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          Expanded(
            child: Text(
              'New Entry',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2B55),
              ),
            ),
          ),
          if (_selectedMood != null)
            ScaleTransition(
              scale: _moodScaleAnim,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _selectedMood!.lightColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedMood!.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Date badge
  // ─────────────────────────────────────────────
  Widget _buildDateBadge() {
    final now = DateTime.now();
    final label = _formatDate(now);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECEAF8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Color(0xFF7C6FCD),
              ),
              const Gap(6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF7C6FCD),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Mood selector section
  // ─────────────────────────────────────────────
  Widget _buildMoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(
          'How are you feeling?',
          subtitle: 'Choose the mood that best describes your day',
        ),
        const Gap(16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(kMoodOptions.length, (index) {
            return _buildMoodTile(index);
          }),
        ),
      ],
    );
  }

  Widget _buildMoodTile(int index) {
    final mood = kMoodOptions[index];
    final isSelected = _selectedMoodIndex == index;

    return GestureDetector(
      onTap: () => _selectMood(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? mood.lightColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? mood.color : const Color(0xFFE8E5F5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: mood.color.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color:
                        const Color(0xFF7C6FCD).withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.elasticOut,
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
            const Gap(8),
            Text(
              mood.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color:
                    isSelected ? mood.color : const Color(0xFF9D95C7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Journal note section
  // ─────────────────────────────────────────────
  Widget _buildNoteSection() {
    final charCount = _noteController.text.length;
    final isNearLimit = charCount > _maxChars * 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionLabel('Write your thoughts'),
            Text(
              '$charCount / $_maxChars',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isNearLimit
                    ? const Color(0xFFFFB830)
                    : const Color(0xFFBBB7DF),
              ),
            ),
          ],
        ),
        const Gap(12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _noteFocusNode.hasFocus
                  ? const Color(0xFF7C6FCD)
                  : const Color(0xFFE8E5F5),
              width: _noteFocusNode.hasFocus ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6FCD).withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _noteController,
            focusNode: _noteFocusNode,
            maxLines: 8,
            minLines: 6,
            maxLength: _maxChars,
            onTap: () => setState(() {}),
            onChanged: (_) => setState(() {}),
            buildCounter: (_,
                    {required currentLength,
                    required isFocused,
                    maxLength}) =>
                null,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF2D2B55),
            ),
            decoration: InputDecoration(
              hintText:
                  'What happened today? How did it make you feel?\n\nDon\'t hold back — this is just for you.',
              hintStyle: GoogleFonts.inter(
                fontSize: 15,
                height: 1.6,
                color: const Color(0xFFCDCAE8),
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Save button
  // ─────────────────────────────────────────────
  Widget _buildSaveButton() {
    final mood = _selectedMood;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _canSave
            ? (mood?.color ?? const Color(0xFF7C6FCD))
            : const Color(0xFFE8E5F5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _canSave
            ? [
                BoxShadow(
                  color: (mood?.color ?? const Color(0xFF7C6FCD))
                      .withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _canSave ? _saveEntry : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_rounded,
                color:
                    _canSave ? Colors.white : const Color(0xFFBBB7DF),
                size: 22,
              ),
              const Gap(10),
              Text(
                _canSave
                    ? 'Save Entry'
                    : 'Select mood & write to save',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color:
                      _canSave ? Colors.white : const Color(0xFFBBB7DF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Shared section label widget
  // ─────────────────────────────────────────────
  Widget _sectionLabel(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D2B55),
          ),
        ),
        if (subtitle != null) ...[
          const Gap(4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9D95C7),
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────
  // Date helper
  // ─────────────────────────────────────────────
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }
}