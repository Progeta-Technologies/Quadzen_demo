import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HabitStatisticsModal extends StatelessWidget {
  final List<Map<String, dynamic>> habits;

  const HabitStatisticsModal({
    super.key,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverallStats(context),
                  SizedBox(height: 3.h),
                  _buildWeeklyTrends(context),
                  SizedBox(height: 3.h),
                  _buildHabitBreakdown(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          Expanded(
            child: Text(
              'Habit Statistics',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          SizedBox(width: 16.w),
        ],
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context) {
    final totalHabits = habits.length;
    final totalCompletions = _getTotalCompletions();
    final averageCompletion =
        totalHabits > 0 ? (totalCompletions / (totalHabits * 30) * 100) : 0;
    final longestStreak = _getLongestStreak();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overall Statistics',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Habits',
                totalHabits.toString(),
                Icons.track_changes,
                Colors.blue,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                context,
                'Completion Rate',
                '${averageCompletion.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Longest Streak',
                '$longestStreak days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildStatCard(
                context,
                'This Week',
                '${_getWeeklyCompletions()}/7',
                Icons.calendar_today,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.toString().split('.').last,
            color: color,
            size: 24,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyTrends(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weekly Trends',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 200,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      if (value.toInt() >= 0 && value.toInt() < days.length) {
                        return Text(
                          days[value.toInt()],
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: habits.length.toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: _getWeeklyTrendData(),
                  isCurved: true,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Breakdown',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        ...habits.map((habit) => _buildHabitStatItem(context, habit)).toList(),
      ],
    );
  }

  Widget _buildHabitStatItem(BuildContext context, Map<String, dynamic> habit) {
    final completionHistory =
        habit['completionHistory'] as Map<String, dynamic>;
    final completionRate = _getHabitCompletionRate(completionHistory);

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: habit['color'] as Color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Text(
                      '${completionRate.toStringAsFixed(1)}% completion',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 4.w),
                    CustomIconWidget(
                      iconName: 'local_fire_department',
                      color: Colors.orange,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${habit['currentStreak']} days',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          CircularProgressIndicator(
            value: completionRate / 100,
            backgroundColor: (habit['color'] as Color).withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(habit['color'] as Color),
          ),
        ],
      ),
    );
  }

  int _getTotalCompletions() {
    int total = 0;
    for (var habit in habits) {
      final completionHistory =
          habit['completionHistory'] as Map<String, dynamic>;
      total += completionHistory.values
          .where((completed) => completed == true)
          .length;
    }
    return total;
  }

  int _getLongestStreak() {
    int longest = 0;
    for (var habit in habits) {
      final streak = habit['currentStreak'] as int;
      if (streak > longest) {
        longest = streak;
      }
    }
    return longest;
  }

  int _getWeeklyCompletions() {
    final today = DateTime.now();
    int weeklyCompletions = 0;

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      int dayCompletions = 0;
      for (var habit in habits) {
        final completionHistory =
            habit['completionHistory'] as Map<String, dynamic>;
        if (completionHistory[dateKey] == true) {
          dayCompletions++;
        }
      }
      weeklyCompletions += dayCompletions;
    }

    return weeklyCompletions;
  }

  List<FlSpot> _getWeeklyTrendData() {
    final today = DateTime.now();
    final spots = <FlSpot>[];

    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: 6 - i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      int dayCompletions = 0;
      for (var habit in habits) {
        final completionHistory =
            habit['completionHistory'] as Map<String, dynamic>;
        if (completionHistory[dateKey] == true) {
          dayCompletions++;
        }
      }

      spots.add(FlSpot(i.toDouble(), dayCompletions.toDouble()));
    }

    return spots;
  }

  double _getHabitCompletionRate(Map<String, dynamic> completionHistory) {
    if (completionHistory.isEmpty) return 0.0;

    final completedDays =
        completionHistory.values.where((completed) => completed == true).length;
    return (completedDays / 30) * 100;
  }
}
