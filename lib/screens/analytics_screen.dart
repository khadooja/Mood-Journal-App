import 'package:gap/gap.dart';
import '../models/mood_option.dart';
import '../models/journal_entry.dart';
import '../widgets/mood_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/mood_analytics_repository.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MoodAnalyticsRepository(
      Hive.box<JournalEntry>('journalBox'),
    );
    final trend = repo.getMoodTrend(days: 7);
    final insights = repo.getInsights();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Mood Trends',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2B55),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF2D2B55),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // SingleChildScrollView fixes the overflow — Column alone can't scroll
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow(trend),
              const Gap(28),
              // ── Calendar ──────────────────────────────────
              Text(
                'Monthly view',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2B55),
                ),
              ),
              const Gap(16),
              const MoodCalendar(),
              const Gap(28),
              // ── 7-day chart ───────────────────────────────
              Text(
                'Last 7 days',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2B55),
                ),
              ),
              const Gap(16),
              _buildChart(trend),
              const Gap(16),
              _buildLegend(),
              // ── Insights ──────────────────────────────────
              if (insights.isNotEmpty) ...[
                const Gap(28),
                Text(
                  'Insights',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2B55),
                  ),
                ),
                const Gap(12),
                _buildInsightsList(insights),
              ],
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary row ───────────────────────────────────────────────────
  Widget _buildSummaryRow(List<MoodDataPoint> trend) {
    final valid = trend.where((p) => p.moodIndex >= 0).toList();
    if (valid.isEmpty) return _buildEmptyState();

    final avg =
        valid.map((p) => p.moodIndex).reduce((a, b) => a + b) / valid.length;
    final avgMood = kMoodOptions[avg.round().clamp(0, 4)];

    return Row(
      children: [
        _buildSummaryCard(
          label: 'Avg mood',
          value: avgMood.emoji,
          sub: avgMood.label,
          color: avgMood.lightColor,
          borderColor: avgMood.color,
        ),
        const Gap(12),
        _buildSummaryCard(
          label: 'Days logged',
          value: '${valid.length}',
          sub: 'out of 7',
          color: const Color(0xFFECEAF8),
          borderColor: const Color(0xFF7C6FCD),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required String value,
    required String sub,
    required Color color,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF9D95C7),
                    fontWeight: FontWeight.w500)),
            const Gap(6),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2B55),
                    height: 1)),
            const Gap(2),
            Text(sub,
                style: GoogleFonts.inter(
                    fontSize: 12, color: const Color(0xFF9D95C7))),
          ],
        ),
      ),
    );
  }

  // ── Line chart ────────────────────────────────────────────────────
  Widget _buildChart(List<MoodDataPoint> trend) {
    const moodColors = [
      Color(0xFF5B8DEF),
      Color(0xFF9B6FDB),
      Color(0xFF7A8FA6),
      Color(0xFF4CAF82),
      Color(0xFFFFB830),
    ];

    final spots = <FlSpot>[];
    for (int i = 0; i < trend.length; i++) {
      if (trend[i].moodIndex >= 0) {
        spots.add(FlSpot(i.toDouble(), trend[i].moodIndex));
      }
    }

    if (spots.isEmpty) return _buildEmptyState();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FCD).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(LineChartData(
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
              const FlLine(color: Color(0xFFE8E5F5), strokeWidth: 1),
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
                return Text(emojis[i],
                    style: const TextStyle(fontSize: 13));
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
                final date = trend[i].date;
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(days[date.weekday - 1],
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF9D95C7),
                          fontWeight: FontWeight.w500)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: const Color(0xFF7C6FCD),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                final c = spot.y.round().clamp(0, 4);
                return FlDotCirclePainter(
                  radius: 5,
                  color: moodColors[c],
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF7C6FCD).withValues(alpha: 0.15),
                  const Color(0xFF7C6FCD).withValues(alpha: 0.0),
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
                    color: mood.color),
              );
            }).toList(),
            getTooltipColor: (_) => Colors.white,
            tooltipRoundedRadius: 10,
            tooltipBorder:
                const BorderSide(color: Color(0xFFE8E5F5)),
          ),
        ),
      )),
    );
  }

  // ── Legend ────────────────────────────────────────────────────────
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
              decoration:
                  BoxDecoration(color: mood.color, shape: BoxShape.circle),
            ),
            const Gap(4),
            Text(mood.label,
                style: GoogleFonts.inter(
                    fontSize: 11, color: const Color(0xFF9D95C7))),
          ],
        );
      }).toList(),
    );
  }

  // ── Insights ──────────────────────────────────────────────────────
  Widget _buildInsightsList(List<String> insights) {
    return Column(
      children: insights.map(_buildInsightCard).toList(),
    );
  }

  Widget _buildInsightCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E5F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C6FCD).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF7C6FCD),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(text,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.5,
                    color: const Color(0xFF2D2B55))),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 40)),
            const Gap(12),
            Text('No data yet',
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2B55))),
            const Gap(6),
            Text('Journal for a few days to see your trend.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF9D95C7))),
          ],
        ),
      ),
    );
  }
}