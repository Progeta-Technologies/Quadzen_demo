import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/habit_creation_modal.dart';
import './widgets/habit_item_widget.dart';
import './widgets/habit_statistics_modal.dart';

class HabitTracker extends StatefulWidget {
  const HabitTracker({super.key});

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  DateTime currentWeek = DateTime.now();
  bool isLoading = false;

  final List<Map<String, dynamic>> habits = [
    {
      "id": 1,
      "name": "Morning Exercise",
      "color": Colors.blue,
      "frequency": "daily",
      "currentStreak": 7,
      "completionHistory": {
        "2025-07-01": true,
        "2025-07-02": true,
        "2025-07-03": false,
        "2025-07-04": true,
        "2025-07-05": true,
        "2025-07-06": true,
        "2025-07-07": true,
        "2025-07-08": true,
        "2025-07-09": false,
        "2025-07-10": true,
        "2025-07-11": false,
      },
      "reminderTime": "07:00",
      "category": "health"
    },
    {
      "id": 2,
      "name": "Read 30 Minutes",
      "color": Colors.green,
      "frequency": "daily",
      "currentStreak": 12,
      "completionHistory": {
        "2025-07-01": true,
        "2025-07-02": true,
        "2025-07-03": true,
        "2025-07-04": true,
        "2025-07-05": false,
        "2025-07-06": true,
        "2025-07-07": true,
        "2025-07-08": true,
        "2025-07-09": true,
        "2025-07-10": true,
        "2025-07-11": true,
      },
      "reminderTime": "20:00",
      "category": "learning"
    },
    {
      "id": 3,
      "name": "Drink 8 Glasses Water",
      "color": Colors.cyan,
      "frequency": "daily",
      "currentStreak": 3,
      "completionHistory": {
        "2025-07-01": false,
        "2025-07-02": true,
        "2025-07-03": false,
        "2025-07-04": false,
        "2025-07-05": true,
        "2025-07-06": false,
        "2025-07-07": true,
        "2025-07-08": false,
        "2025-07-09": true,
        "2025-07-10": true,
        "2025-07-11": false,
      },
      "reminderTime": "09:00",
      "category": "health"
    },
    {
      "id": 4,
      "name": "Meditation",
      "color": Colors.purple,
      "frequency": "daily",
      "currentStreak": 5,
      "completionHistory": {
        "2025-07-01": true,
        "2025-07-02": false,
        "2025-07-03": true,
        "2025-07-04": true,
        "2025-07-05": true,
        "2025-07-06": false,
        "2025-07-07": true,
        "2025-07-08": true,
        "2025-07-09": true,
        "2025-07-10": false,
        "2025-07-11": true,
      },
      "reminderTime": "06:30",
      "category": "wellness"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshHabits,
        child: habits.isEmpty ? _buildEmptyState() : _buildHabitsList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHabitCreationModal,
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        child: CustomIconWidget(
          iconName: 'add',
          color: AppTheme.lightTheme.colorScheme.onSecondary,
          size: 24,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: Theme.of(context).appBarTheme.foregroundColor!,
          size: 24,
        ),
      ),
      title: Text(
        'Habit Tracker',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).appBarTheme.foregroundColor,
              fontWeight: FontWeight.w600,
            ),
      ),
      actions: [
        IconButton(
          onPressed: _showStatisticsModal,
          icon: CustomIconWidget(
            iconName: 'bar_chart',
            color: Theme.of(context).appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
        IconButton(
          onPressed: _showHabitCreationModal,
          icon: CustomIconWidget(
            iconName: 'add',
            color: Theme.of(context).appBarTheme.foregroundColor!,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousWeek,
            icon: CustomIconWidget(
              iconName: 'chevron_left',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          Expanded(
            child: Text(
              _getWeekRangeText(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          IconButton(
            onPressed: _nextWeek,
            icon: CustomIconWidget(
              iconName: 'chevron_right',
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(4.w),
          child: _buildWeekNavigation(),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: habits.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return HabitItemWidget(
                habit: habit,
                onToggleCompletion: (date) =>
                    _toggleHabitCompletion(index, date),
                onEdit: () => _editHabit(index),
                onDelete: () => _deleteHabit(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'track_changes',
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
              size: 80,
            ),
            SizedBox(height: 3.h),
            Text(
              'Start Building Habits',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Create your first habit to begin tracking your daily progress and building positive routines.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            _buildSuggestedCategories(),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _showHabitCreationModal,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Theme.of(context).colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Create Your First Habit'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedCategories() {
    final categories = [
      {'name': 'Health', 'icon': 'favorite', 'color': Colors.red},
      {'name': 'Productivity', 'icon': 'work', 'color': Colors.blue},
      {'name': 'Learning', 'icon': 'school', 'color': Colors.green},
      {'name': 'Wellness', 'icon': 'spa', 'color': Colors.purple},
    ];

    return Column(
      children: [
        Text(
          'Suggested Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.h,
          children: categories.map((category) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: (category['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (category['color'] as Color).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: category['icon'] as String,
                    color: category['color'] as Color,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    category['name'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: category['color'] as Color,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _previousWeek() {
    setState(() {
      currentWeek = currentWeek.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      currentWeek = currentWeek.add(const Duration(days: 7));
    });
  }

  String _getWeekRangeText() {
    final startOfWeek =
        currentWeek.subtract(Duration(days: currentWeek.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  void _toggleHabitCompletion(int habitIndex, String date) {
    HapticFeedback.lightImpact();
    setState(() {
      final habit = habits[habitIndex];
      final completionHistory =
          habit['completionHistory'] as Map<String, dynamic>;
      completionHistory[date] = !(completionHistory[date] ?? false);

      // Recalculate streak
      habit['currentStreak'] = _calculateStreak(completionHistory);
    });
  }

  int _calculateStreak(Map<String, dynamic> completionHistory) {
    int streak = 0;
    final today = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final date = today.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (completionHistory[dateKey] == true) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  void _editHabit(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitCreationModal(
        habit: habits[index],
        onSave: (updatedHabit) {
          setState(() {
            habits[index] = updatedHabit;
          });
        },
      ),
    );
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text(
            'Are you sure you want to delete "${habits[index]['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                habits.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHabitCreationModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitCreationModal(
        onSave: (newHabit) {
          setState(() {
            habits.add({
              ...newHabit,
              'id': habits.length + 1,
              'currentStreak': 0,
              'completionHistory': <String, dynamic>{},
            });
          });
        },
      ),
    );
  }

  void _showStatisticsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HabitStatisticsModal(habits: habits),
    );
  }

  Future<void> _refreshHabits() async {
    setState(() {
      isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
      // Recalculate all streaks
      for (var habit in habits) {
        habit['currentStreak'] = _calculateStreak(habit['completionHistory']);
      }
    });
  }
}
