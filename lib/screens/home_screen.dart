import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../models/journal_entry.dart';
import '../repositories/mood_analytics_repository.dart';
import '../widgets/entry_tile.dart';
import '../widgets/home_new_entry_button.dart';
import '../widgets/home_stat_cards.dart';
import '../widgets/home_summary_card.dart';
import '../widgets/mood_strip.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/streak_badge.dart';
import 'add_entry_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MoodAnalyticsRepository _analyticsRepo;
  int _streak = 0;
  String _searchQuery = '';
  int? _searchMood;

  @override
  void initState() {
    super.initState();
    final box = Hive.box<JournalEntry>('journal_entries');
    _analyticsRepo = MoodAnalyticsRepository(box);
    _streak = _analyticsRepo.getStreak();
  }

  void _refreshStreak() {
    setState(() => _streak = _analyticsRepo.getStreak());
  }

  void _onSearch({String? query, int? mood}) {
    setState(() {
      _searchQuery = query ?? _searchQuery;
      _searchMood = mood;
    });
    context.read<JournalCubit>().searchEntries(
          query: _searchQuery,
          moodIndex: _searchMood,
        );
  }

  Future<void> _onAddEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEntryScreen()),
    );
    if (mounted) {
      context.read<JournalCubit>().loadEntries();
      _refreshStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<JournalCubit, JournalState>(
      listener: (context, state) {
        if (state is JournalLoaded) _refreshStreak();
      },
      builder: (context, state) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            backgroundColor: AppColors.backgroundGradientStart,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.backgroundGradientStart,
                    AppColors.backgroundGradientEnd,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    _buildHeader(state),
                    ..._buildBody(state),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Greeting header (always shown) ──────────────────────────────────────

  SliverToBoxAdapter _buildHeader(JournalState state) {
    final now = DateTime.now();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.xl,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row: greeting + settings ─────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greetingText(now.hour),
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(now),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Streak badge + settings button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Settings button
                    GestureDetector(
                      onTap: () {
                        // TODO: navigate to Settings
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_outlined,
                          size: 19,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    if (_streak > 0) ...[
                      const SizedBox(height: AppSpacing.sm),
                      StreakBadge(streak: _streak),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Weekly mood strip ─────────────────────────────
            const MoodStrip(),
            const SizedBox(height: AppSpacing.lg),

            // ── Daily prompt card ─────────────────────────────
            HomeSummaryCard(
              entries: state is JournalLoaded ? state.entries : const [],
              streak: _streak,
              onTap: _onAddEntry,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── 4-up stat cards ───────────────────────────────
            HomeStatCards(
              entries: state is JournalLoaded ? state.entries : const [],
              streak: _streak,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Full-width CTA button ─────────────────────────
            HomeNewEntryButton(onTap: _onAddEntry),
            const SizedBox(height: AppSpacing.xxl),

            // ── Section header: Recent Entries ────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Entries', style: AppTextStyles.sectionLabel),
                if (state is JournalLoaded && state.entries.isNotEmpty)
                  Text(
                    '${state.entries.length} total',
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Search bar ────────────────────────────────────
            JournalSearchBar(
              onTextChanged: (q) => _onSearch(query: q),
              onMoodChanged: (m) => _onSearch(mood: m),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  // ── Body slivers (state-dependent) ──────────────────────────────────────

  List<Widget> _buildBody(JournalState state) {
    if (state is JournalInitial || state is JournalLoading) {
      return [_buildLoadingState()];
    }
    if (state is JournalError) {
      return [_buildErrorState(state.message)];
    }
    if (state is JournalLoaded) {
      if (state.entries.isEmpty &&
          (_searchQuery.isNotEmpty || _searchMood != null)) {
        return [_buildNoResultsState()];
      }
      if (state.entries.isEmpty) {
        return [_buildEmptyState()];
      }
      return [_buildEntryList(state.entries)];
    }
    return [_buildEmptyState()];
  }

  // ── Loading ──────────────────────────────────────────────────────────────

  SliverFillRemaining _buildLoadingState() {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────────

  SliverFillRemaining _buildErrorState(String message) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Text(
            message,
            style: AppTextStyles.body.copyWith(color: AppColors.errorAccent),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // ── Premium empty state ──────────────────────────────────────────────────

  SliverFillRemaining _buildEmptyState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration orb
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accentLavender, AppColors.accentRose],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌱', style: TextStyle(fontSize: 42)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Your journey starts here',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your journey starts with one reflection 🌱\nWrite your first entry and begin your wellness story.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Mini CTA
              GestureDetector(
                onTap: _onAddEntry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDeep],
                    ),
                    borderRadius: AppRadius.fullAll,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Write your first entry',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── No-results state ─────────────────────────────────────────────────────

  SliverFillRemaining _buildNoResultsState() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statEntriesBg,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 32)),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No matches found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Try a different keyword or mood filter.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  // ── Entry list ───────────────────────────────────────────────────────────

  SliverPadding _buildEntryList(List<JournalEntry> entries) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl, 0, AppSpacing.xl, 140,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: EntryTile(entry: entries[index]),
          ),
          childCount: entries.length,
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _greetingText(int hour) {
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤';
    if (hour < 21) return 'Good evening 🌙';
    return 'Good night 🌌';
  }


  String _formatDate(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }
}
