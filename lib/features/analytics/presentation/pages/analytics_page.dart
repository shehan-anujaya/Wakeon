import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/driving_session.dart';
import '../../providers/analytics_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  @override
  void initState() {
    super.initState();
    // Load analytics data when page opens
    Future.microtask(() {
      ref.read(analyticsProvider.notifier).loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: AppTheme.neonBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ANALYTICS',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Safety Insights',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Summary Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: analytics.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue))
                    : Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              icon: Icons.timer_outlined,
                              label: 'Total Hours',
                              value: analytics.formattedTotalTime,
                              color: AppTheme.neonGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              icon: Icons.warning_amber_rounded,
                              label: 'Alerts',
                              value: '${analytics.totalAlerts}',
                              color: AppTheme.neonAmber,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: analytics.isLoading
                    ? const SizedBox.shrink()
                    : Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              icon: Icons.drive_eta_outlined,
                              label: 'Sessions',
                              value: '${analytics.totalSessions}',
                              color: AppTheme.neonBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              icon: Icons.emoji_events_outlined,
                              label: 'Safety Score',
                              value: analytics.formattedSafetyScore,
                              color: AppTheme.neonPurple,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 32)),

            // Weekly Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEKLY DRIVING HOURS',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textTertiary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: _buildWeeklyChart(analytics),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 32)),

            // Recent Sessions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT SESSIONS',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textTertiary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (analytics.recentSessions.isNotEmpty)
                      Text(
                        '${analytics.recentSessions.length} sessions',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(top: 16)),

            if (analytics.recentSessions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.drive_eta_outlined,
                          size: 48,
                          color: AppTheme.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sessions yet',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start driving to see your history here',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = analytics.recentSessions[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                      child: _buildRealSessionCard(context, session),
                    );
                  },
                  childCount: analytics.recentSessions.length,
                ),
              ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build the weekly driving hours chart with real data
  Widget _buildWeeklyChart(AnalyticsData analytics) {
    // Generate spots from weeklyDrivingHours map
    final spots = <FlSpot>[];
    double maxY = 1.0; // Minimum max to avoid 0 range
    
    for (int i = 0; i < 7; i++) {
      final hours = analytics.weeklyDrivingHours[i] ?? 0.0;
      spots.add(FlSpot(i.toDouble(), hours));
      if (hours > maxY) maxY = hours;
    }
    
    // Round up maxY to nearest whole number for better chart display
    maxY = (maxY.ceil()).toDouble();
    if (maxY < 1) maxY = 1;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.surfaceLight,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  '${value.toStringAsFixed(1)}h',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textTertiary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[value.toInt()],
                      style: GoogleFonts.outfit(
                        color: AppTheme.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.neonGreen,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppTheme.backgroundBlack,
                  strokeWidth: 2,
                  strokeColor: AppTheme.neonGreen,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.neonGreen.withOpacity(0.2),
                  AppTheme.neonGreen.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: maxY,
      ),
    );
  }

  /// Build a session card with real session data
  Widget _buildRealSessionCard(BuildContext context, DrivingSession session) {
    final isCleanSession = session.drowsinessEventsCount == 0;
    final statusColor = isCleanSession ? AppTheme.neonGreen : AppTheme.neonAmber;
    
    // Format the date
    final now = DateTime.now();
    final sessionDate = session.startTime;
    String dateText;
    
    if (DateUtils.isSameDay(now, sessionDate)) {
      dateText = 'Today';
    } else if (DateUtils.isSameDay(now.subtract(const Duration(days: 1)), sessionDate)) {
      dateText = 'Yesterday';
    } else {
      final difference = now.difference(sessionDate).inDays;
      if (difference < 7) {
        dateText = '$difference days ago';
      } else {
        dateText = DateFormat('MMM d').format(sessionDate);
      }
    }
    
    // Format duration
    final duration = session.duration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    String durationText;
    if (hours == 0) {
      durationText = '${minutes}m';
    } else if (minutes == 0) {
      durationText = '${hours}h';
    } else {
      durationText = '${hours}h ${minutes}m';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCleanSession ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateText,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      durationText,
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${session.drowsinessEventsCount} alert${session.drowsinessEventsCount == 1 ? '' : 's'}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: session.drowsinessEventsCount > 0 ? AppTheme.neonAmber : AppTheme.textSecondary,
                        fontWeight: session.drowsinessEventsCount > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppTheme.textTertiary,
          ),
        ],
      ),
    );
  }
}
