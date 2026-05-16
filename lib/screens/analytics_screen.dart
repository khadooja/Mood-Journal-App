import '../models/mood_option.dart';
import '../models/journal_entry.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_card.dart';
import '../widgets/mood_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/mood_analytics_repository.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MoodAnalyticsRepository(
      Hive.box<JournalEntry>('journal_entries'),
    );
    final trend = repo.getMoodTrend(days: 7);
    final insights = repo.getInsights();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Sticky header ──────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleSpacing: AppSpacing.xl,
              automaticallyImplyLeading: false,
              title: Text('Mood Trends', style: AppTextStyles.title),
            ),

            // ── Content ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryRow(trend),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Monthly View', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSpacing.lg),
                  const MoodCalendar(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Last 7 Days', style: AppTextStyles.sectionLabel),
                  const SizedBox(height: AppSpacing.lg),
                  _buildChart(trend),
                  const SizedBox(height: AppSpacing.md),
                  _buildLegend(),
                  if (insights.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xxl),
                    Text('Insights', style: AppTextStyles.sectionLabel),
                    const SizedBox(height: AppSpacing.md),
                    ..._buildInsights(insights),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary row ─────────────────────────────────────────────────────────

  Widget _buildSummaryRow(List<MoodDataPoint> trend) {
    final valid = trend.where((p) => p.moodIndex >= 0).toList();
    if (valid.isEmpty) return _buildEmptyState();

    final avg =
        valid.map((p) => p.moodIndex).reduce((a, b) => a + b) / valid.length;
    final avgMood = kMoodOptions[avg.round().clamp(0, 4)];

    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avg mood', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  avgMood.emoji,
                  style: const TextStyle(fontSize: 28, height: 1),
                ),
                const SizedBox(height: 2),
                Text(avgMood.label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Days logged', style: AppTextStyles.labelMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${valid.length}',
                  style: AppTextStyles.displayLarge.copyWith(height: 1),
                ),
                const SizedBox(height: 2),
                Text('out of 7', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Line chart ──────────────────────────────────────────────────────────

  Widget _buildChart(List<MoodDataPoint> trend) {
    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      if (trend[i].moodIndex >= 0) {
        spots.add(FlSpot(i.toDouble(), trend[i].moodIndex.toDouble()));
      }
    }

    if (spots.isEmpty) return _buildEmptyState();

    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 4,
            minX: 0,
            maxX: 6,
            clipData: const FlClipData.all(),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) =>
                  const FlLine(color: AppColors.borderLight, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) {
                    const emojis = ['😢', '😟', '😐', '😊', '😄'];
                    final i = value.toInt();
                    if (i < 0 || i > 4) return const SizedBox.shrink();
                    return Text(
                      emojis[i],
                      style: const TextStyle(fontSize: 13),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= trend.length) {
                      return const SizedBox.shrink();
                    }
                    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text(
                        days[trend[i].date.weekday - 1],
                        style: AppTextStyles.labelMedium,
                      ),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                color: AppColors.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, _, _) {
                    final c = spot.y.round().clamp(0, 4);
                    return FlDotCirclePainter(
                      radius: 5,
                      color: AppColors.moodChartColors[c],
                      strokeWidth: 2,
                      strokeColor: AppColors.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (spots) => spots.map((spot) {
                  final mood = kMoodOptions[spot.y.round().clamp(0, 4)];
                  return LineTooltipItem(
                    '${mood.emoji} ${mood.label}',
                    GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: mood.color,
                    ),
                  );
                }).toList(),
                getTooltipColor: (_) => AppColors.surface,
                tooltipRoundedRadius: AppRadius.xs.toDouble(),
                tooltipBorder: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Legend ──────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: kMoodOptions.map((mood) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: mood.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(mood.label, style: AppTextStyles.labelSmall),
          ],
        );
      }).toList(),
    );
  }

  // ── Insights ─────────────────────────────────────────────────────────────

  List<Widget> _buildInsights(List<String> insights) {
    return insights.map((text) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 6, right: AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(child: Text(text, style: AppTextStyles.body)),
            ],
          ),
        ),
      );
    }).toList();
  }

  // ── Empty state ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 38)),
            const SizedBox(height: AppSpacing.md),
            Text('No data yet', style: AppTextStyles.sectionLabel),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Journal for a few days to see your trend.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}
