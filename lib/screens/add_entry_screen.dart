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
import '../services/ai_service.dart';
import '../services/first_entry_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});
  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedMoodIndex;
  final _noteCtrl = TextEditingController();
  final _noteFocus = FocusNode();
  late final AnimationController _moodAnims;
  late final Animation<double> _moodScale;
  static const _maxChars = 500;

  bool _isAnalyzing = false;
  Map<String, dynamic>? _aiResult;
  String? _aiError;

  @override
  void initState() {
    super.initState();
    _moodAnims = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _moodScale = CurvedAnimation(parent: _moodAnims, curve: Curves.elasticOut);
    _noteCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _moodAnims.dispose();
    _noteCtrl.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  bool get _canSave => _selectedMoodIndex != null && _noteCtrl.text.trim().isNotEmpty;
  bool get _canAnalyze => _noteCtrl.text.trim().length >= 10 && !_isAnalyzing;
  MoodOption? get _mood => _selectedMoodIndex != null ? kMoodOptions[_selectedMoodIndex!] : null;

  void _selectMood(int i) {
    HapticFeedback.lightImpact();
    setState(() => _selectedMoodIndex = i);
    _moodAnims.forward(from: 0);
  }

  Future<void> _analyzeWithAI() async {
    final text = _noteCtrl.text.trim();
    if (text.isEmpty) return;
    _noteFocus.unfocus();
    setState(() { _isAnalyzing = true; _aiResult = null; _aiError = null; });
    try {
      final result = await context.read<JournalCubit>().analyzeEntry(text);
      final idx = (result['moodIndex'] as num).toInt().clamp(0, 4);
      setState(() { _isAnalyzing = false; _aiResult = result; _selectedMoodIndex = idx; });
      _moodAnims.forward(from: 0);
      HapticFeedback.lightImpact();
    } on AiServiceException catch (e) {
      setState(() { _isAnalyzing = false; _aiError = e.message; });
    } catch (_) {
      setState(() { _isAnalyzing = false; _aiError = 'Something went wrong. Please try again.'; });
    }
  }

  void _saveEntry() async {
    if (!_canSave) return;
    HapticFeedback.mediumImpact();
    _noteFocus.unfocus();
    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      moodIndex: _selectedMoodIndex!,
      note: _noteCtrl.text.trim(),
      date: DateTime.now(),
    );
    final isFirst = await FirstEntryService.isFirstEntry();
    if (!mounted) return;
    context.read<JournalCubit>().addEntry(entry);
    if (isFirst) {
      await FirstEntryService.markFirstEntrySaved();
      if (!mounted) return;
      _showFirstEntrySheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Text(_mood!.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          const Text('Entry saved!'),
        ]),
        backgroundColor: _mood!.color,
      ));
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: AppSpacing.sm),
                _buildDateBadge(),
                const SizedBox(height: AppSpacing.xxl),
                _buildMoodSection(),
                const SizedBox(height: AppSpacing.xxl),
                _buildNoteSection(),
                const SizedBox(height: AppSpacing.lg),
                if (_aiResult != null) ...[_buildAiResultCard(), const SizedBox(height: AppSpacing.md)],
                if (_aiError != null) ...[_buildAiErrorCard(), const SizedBox(height: AppSpacing.md)],
                AppButton.secondary(
                  label: _aiResult != null ? 'Re-analyze with AI ✨' : 'Analyze with AI ✨',
                  onPressed: _canAnalyze ? _analyzeWithAI : null,
                  isLoading: _isAnalyzing,
                  leadingIcon: _isAnalyzing ? null : const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton.primary(
                  label: _canSave ? 'Save Entry' : 'Select mood & write to save',
                  onPressed: _canSave ? _saveEntry : null,
                  backgroundColor: _canSave ? _mood?.color : null,
                  leadingIcon: Icon(Icons.check_rounded, size: 20,
                      color: _canSave ? AppColors.surface : AppColors.textHint),
                ),
                const SizedBox(height: AppSpacing.xl),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.lg, 0),
      child: Row(children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(child: Text('New Entry', style: AppTextStyles.title)),
        if (_mood != null)
          ScaleTransition(
            scale: _moodScale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: AppDecorations.pill(color: _mood!.lightColor),
              child: Text(_mood!.emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
      ]),
    );
  }

  Widget _buildDateBadge() {
    final now = DateTime.now();
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const w = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppRadius.fullAll),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Text('${w[now.weekday-1]}, ${m[now.month-1]} ${now.day}',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildMoodSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How are you feeling?', style: AppTextStyles.sectionLabel),
      const SizedBox(height: AppSpacing.xs),
      Text('Choose the mood that best describes your day', style: AppTextStyles.caption),
      const SizedBox(height: AppSpacing.lg),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(kMoodOptions.length, _buildMoodTile),
      ),
    ]);
  }

  Widget _buildMoodTile(int index) {
    final mood = kMoodOptions[index];
    final sel  = _selectedMoodIndex == index;
    final aiPick = _aiResult != null && sel;
    return GestureDetector(
      onTap: () => _selectMood(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: sel ? mood.lightColor : AppColors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: sel ? mood.color : AppColors.borderLight, width: sel ? 2 : 1),
          boxShadow: sel
              ? [BoxShadow(color: mood.color.withValues(alpha: aiPick ? 0.28 : 0.16), blurRadius: aiPick ? 16 : 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedScale(
            scale: sel ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.elasticOut,
            child: Text(mood.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(mood.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                color: sel ? mood.color : AppColors.textSecondary,
              )),
        ]),
      ),
    );
  }

  Widget _buildNoteSection() {
    final len = _noteCtrl.text.length;
    final near = len > _maxChars * 0.8;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Write your thoughts', style: AppTextStyles.sectionLabel),
        Text('$len / $_maxChars',
            style: AppTextStyles.labelMedium.copyWith(
                color: near ? AppColors.warning : AppColors.textHint, fontWeight: FontWeight.w500)),
      ]),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _noteCtrl,
        focusNode: _noteFocus,
        maxLines: 8,
        minLines: 6,
        maxLength: _maxChars,
        hintText: "What happened today? How did it make you feel?\n\nDon't hold back — this is just for you.",
        onChanged: (_) => setState(() {}),
        onTap: () => setState(() {}),
      ),
    ]);
  }

  Widget _buildAiResultCard() {
    final r    = _aiResult!;
    final idx  = (r['moodIndex'] as num).toInt().clamp(0, 4);
    final mood = kMoodOptions[idx];
    final pct  = (((r['confidence'] as num?) ?? 0.0).toDouble() * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: mood.lightColor,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: mood.color.withValues(alpha: 0.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Text(mood.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: AppSpacing.xs),
          Text('$pct%', style: AppTextStyles.labelSmall.copyWith(color: mood.color, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(mood.label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, color: mood.color)),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(color: mood.color.withValues(alpha: 0.15), borderRadius: AppRadius.fullAll),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.auto_awesome, size: 10, color: mood.color),
                  const SizedBox(width: 3),
                  Text('AI', style: AppTextStyles.labelSmall.copyWith(color: mood.color, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
            const SizedBox(height: AppSpacing.xs),
            Text(r['insight'] as String? ?? '', style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: AppSpacing.sm),
            Text('Mood auto-selected · tap any mood to change', style: AppTextStyles.labelSmall),
          ]),
        ),
      ]),
    );
  }

  Widget _buildAiErrorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.errorIcon),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text('Could not analyze. Check your API key or try again.',
              style: AppTextStyles.caption.copyWith(color: AppColors.errorText)),
        ),
      ]),
    );
  }

  void _showFirstEntrySheet() {
    final mood = _mood!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxxl, AppSpacing.xxl, AppSpacing.h),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: AppRadius.fullAll)),
          const SizedBox(height: AppSpacing.xxl),
          Container(width: 80, height: 80,
            decoration: BoxDecoration(color: mood.lightColor, shape: BoxShape.circle),
            child: Center(child: Text(mood.emoji, style: const TextStyle(fontSize: 40))),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Your journey starts today', style: AppTextStyles.title, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'You just saved your first entry.\nYour streak starts now — come back tomorrow to keep it going 🔥',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          AppButton.primary(
            label: "Let's go",
            backgroundColor: mood.color,
            onPressed: () { Navigator.of(context).pop(); Navigator.of(context).pop(); },
          ),
        ]),
      ),
    );
  }
}
