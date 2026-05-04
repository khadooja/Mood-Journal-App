import 'package:gap/gap.dart';
import '../models/mood_option.dart';
import '../cubit/journal_cubit.dart';
import '../services/ai_service.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindtrack/services/first_entry_service.dart';

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

  // ── AI state ────────────────────────────────────────────
  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiResult;
  String? _aiError;

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

  bool get _canAnalyze =>
      _noteController.text.trim().length >= 10 && !_isAnalyzing;

  MoodOption? get _selectedMood =>
      _selectedMoodIndex != null ? kMoodOptions[_selectedMoodIndex!] : null;

  // ── Mood selection ──────────────────────────────────────
  void _selectMood(int index) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMoodIndex = index);
    _moodAnimController.forward(from: 0);
  }

  // ── AI analyze ──────────────────────────────────────────
  Future<void> _analyzeWithAI() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    _noteFocusNode.unfocus();
    setState(() {
      _isAnalyzing = true;
      _aiResult = null;
      _aiError = null;
    });

    try {
      // PHASE 1: one API call — returns structured result
      final result = await context.read<JournalCubit>().analyzeEntry(text);

      // PHASE 2: auto-set mood from AI result (user can still override)
      final suggestedIndex = (result['moodIndex'] as num).toInt().clamp(0, 4);

      setState(() {
        _isAnalyzing = false;
        _aiResult = result;
        _selectedMoodIndex = suggestedIndex; // auto-suggest
      });
      _moodAnimController.forward(from: 0);
      HapticFeedback.lightImpact();
    } on AiServiceException catch (e) {
      setState(() {
        _isAnalyzing = false;
        _aiError = e.message;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _aiError = 'Something went wrong. Please try again.';
      });
    }
  }

  // ── Save entry ──────────────────────────────────────────
  void _saveEntry() async {
  if (!_canSave) return;
  HapticFeedback.mediumImpact();
  _noteFocusNode.unfocus();

  final entry = JournalEntry(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    moodIndex: _selectedMoodIndex!,
    note: _noteController.text.trim(),
    date: DateTime.now(),
  );

  // Check BEFORE saving so the flag is still false
  final isFirst = await FirstEntryService.isFirstEntry();

  if (!mounted) return;
  context.read<JournalCubit>().addEntry(entry);

  if (isFirst) {
    await FirstEntryService.markFirstEntrySaved();
    if (!mounted) return;
    _showFirstEntrySheet();
  } else {
    // Normal save — existing snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(_selectedMood!.emoji, style: const TextStyle(fontSize: 18)),
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
                    const Gap(16),
                    // ── PHASE 1: AI result card (shown after analysis) ──
                    if (_aiResult != null) _buildAiResultCard(),
                    if (_aiError != null) _buildAiErrorCard(),
                    const Gap(12),
                    // ── PHASE 1: Analyze button ─────────────────────────
                    _buildAnalyzeButton(),
                    const Gap(12),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
    // Show subtle AI-suggested glow when auto-selected by AI
    final isAiSuggested = _aiResult != null && isSelected;

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
                    color: mood.color.withValues(
                      alpha: isAiSuggested ? 0.35 : 0.25,
                    ),
                    blurRadius: isAiSuggested ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF7C6FCD).withValues(alpha: 0.05),
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
              child: Text(mood.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const Gap(8),
            Text(
              mood.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? mood.color : const Color(0xFF9D95C7),
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
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
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
  // PHASE 1 — AI result card
  // ─────────────────────────────────────────────
  Widget _buildAiResultCard() {
    final result = _aiResult!;
    final moodIndex = (result['moodIndex'] as num).toInt().clamp(0, 4);
    final mood = kMoodOptions[moodIndex];
    final insight = result['insight'] as String? ?? '';
    final confidence = ((result['confidence'] as num?) ?? 0.0).toDouble();
    final confidencePct = (confidence * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mood.lightColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mood.color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji + confidence
          Column(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 28)),
              const Gap(4),
              Text(
                '$confidencePct%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: mood.color,
                ),
              ),
            ],
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      mood.label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: mood.color,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: mood.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 10,
                            color: mood.color,
                          ),
                          const Gap(3),
                          Text(
                            'AI',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: mood.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(6),
                Text(
                  insight,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.5,
                    color: const Color(0xFF2D2B55),
                  ),
                ),
                const Gap(8),
                Text(
                  'Mood auto-selected · tap any mood to change',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF9D95C7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PHASE 1 — AI error card
  // ─────────────────────────────────────────────
  Widget _buildAiErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB3B3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 18, color: Color(0xFFE57373)),
          const Gap(10),
          Expanded(
            child: Text(
              'Could not analyze. Check your API key or try again.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFFB71C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PHASE 1 — Analyze with AI button
  // ─────────────────────────────────────────────
  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _canAnalyze ? _analyzeWithAI : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: _canAnalyze
                ? const Color(0xFF7C6FCD)
                : const Color(0xFFE8E5F5),
            width: 1.5,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: _canAnalyze
              ? const Color(0xFF7C6FCD).withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: _isAnalyzing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFF7C6FCD),
                    ),
                  ),
                  const Gap(10),
                  Text(
                    'Analyzing...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF7C6FCD),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: Color(0xFF7C6FCD),
                  ),
                  const Gap(8),
                  Text(
                    _aiResult != null
                        ? 'Re-analyze with AI ✨'
                        : 'Analyze with AI ✨',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _canAnalyze
                          ? const Color(0xFF7C6FCD)
                          : const Color(0xFFBBB7DF),
                    ),
                  ),
                ],
              ),
      ),
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
                  color: (mood?.color ?? const Color(0xFF7C6FCD)).withValues(
                    alpha: 0.35,
                  ),
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
                color: _canSave ? Colors.white : const Color(0xFFBBB7DF),
                size: 22,
              ),
              const Gap(10),
              Text(
                _canSave ? 'Save Entry' : 'Select mood & write to save',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _canSave ? Colors.white : const Color(0xFFBBB7DF),
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
  void _showFirstEntrySheet() {
  final mood = _selectedMood!;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: false,       // user must tap the button — intentional moment
    enableDrag: false,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle — visual only
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E5F5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(28),
          // Mood emoji — large, celebratory
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: mood.lightColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                mood.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const Gap(20),
          Text(
            'Your journey starts today',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2B55),
            ),
          ),
          const Gap(10),
          Text(
            'You just saved your first entry.\nYour streak starts now — come back tomorrow to keep it going 🔥',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: const Color(0xFF9D95C7),
            ),
          ),
          const Gap(32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close sheet
                Navigator.of(context).pop(); // return to HomeScreen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mood.color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Let\'s go',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
