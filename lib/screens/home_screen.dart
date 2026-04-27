import 'package:gap/gap.dart';
import 'add_entry_screen.dart';
import '../cubit/journal_cubit.dart';
import '../cubit/journal_state.dart';
import '../models/journal_entry.dart';
import '../widgets/entry_tile.dart';
import '../widgets/mood_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<JournalCubit, JournalState>(
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                _buildGreetingHeader(context),
                if (state is JournalInitial || state is JournalLoading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is JournalError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else if (state is JournalLoaded && state.entries.isEmpty)
                  _buildEmptyState(context)
                else if (state is JournalLoaded)
                  _buildEntryList(context, state.entries)
                else
                  _buildEmptyState(context),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // ────────────────────────────────────────────────
  // App Bar — minimal, no elevation
  // ────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: const Color(0xFFF8F7FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF7C6FCD),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
          const Gap(10),
          Text(
            'MindTrack',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2D2B55),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Color(0xFF2D2B55)),
          onPressed: () {
            // TODO: Search entries (future step)
          },
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Color(0xFF2D2B55)),
          onPressed: () {
            // TODO: Navigate to Settings (future step)
          },
          tooltip: 'Settings',
        ),
        const Gap(4),
      ],
    );
  }

  // ────────────────────────────────────────────────
  // Greeting header — dynamic day greeting + date
  // ────────────────────────────────────────────────
  SliverToBoxAdapter _buildGreetingHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    final dateLabel = _formatDate(now);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF2D2B55),
                height: 1.2,
              ),
            ),
            const Gap(6),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF9D95C7),
                ),
                const Gap(6),
                Text(
                  dateLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9D95C7),
                  ),
                ),
              ],
            ),
            const Gap(20),
            const MoodStrip(), // BlocBuilder inside — const is fine at this level
            const Gap(24),
            Text(
              'Journal Entries',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2B55),
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ────────────────────────────────────────────────
  // Entry list — rendered when JournalLoaded & non-empty
  // ────────────────────────────────────────────────
  SliverPadding _buildEntryList(
    BuildContext context,
    List<JournalEntry> entries,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildEntryCard(context, entries[index]),
          childCount: entries.length,
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    return EntryTile(entry: entry);
  }

  // ────────────────────────────────────────────────
  // Empty state — shown when no journal entries exist
  // ────────────────────────────────────────────────
  SliverFillRemaining _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF7C6FCD).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.book_outlined,
                size: 52,
                color: Color(0xFF7C6FCD),
              ),
            ),
            const Gap(24),
            Text(
              'Your journal is empty',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D2B55),
              ),
            ),
            const Gap(10),
            Text(
              'Tap the + button to write your\nfirst mood entry for today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9D95C7),
                height: 1.5,
              ),
            ),
            const Gap(32),
            Column(
              children: [
                Text(
                  'Start here',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFFBBB7DF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Gap(6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFBBB7DF),
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Floating Action Button
  // ────────────────────────────────────────────────
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddEntryScreen()));
        if (context.mounted) {
          context.read<JournalCubit>().loadEntries();
        }
      },
      backgroundColor: const Color(0xFF7C6FCD),
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.edit_rounded, size: 20),
      label: Text(
        'New Entry',
        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    );
  }

  // ────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────
  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning 🌤';
    if (hour < 17) return 'Good afternoon ☀️';
    if (hour < 21) return 'Good evening 🌙';
    return 'Good night 🌌';
  }

  String _formatDate(DateTime date) {
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
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }


}
