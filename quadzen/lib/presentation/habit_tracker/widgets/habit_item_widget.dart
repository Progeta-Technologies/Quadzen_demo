import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HabitItemWidget extends StatelessWidget {
  final Map<String, dynamic> habit;
  final Function(String) onToggleCompletion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitItemWidget({
    super.key,
    required this.habit,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(habit['id'].toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        HapticFeedback.mediumImpact();
        return await _showDeleteConfirmation(context);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: CustomIconWidget(
          iconName: 'delete',
          color: Colors.white,
          size: 24,
        ),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitHeader(context),
            SizedBox(height: 2.h),
            _buildCompletionGrid(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: habit['color'] as Color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              HapticFeedback.mediumImpact();
              onEdit();
            },
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
                    CustomIconWidget(
                      iconName: 'local_fire_department',
                      color: habit['currentStreak'] > 0
                          ? Colors.orange
                          : Colors.grey,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${habit['currentStreak']} day streak',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: habit['currentStreak'] > 0
                                ? Colors.orange
                                : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _buildTodayCheckbox(context),
      ],
    );
  }

  Widget _buildTodayCheckbox(BuildContext context) {
    final today = DateTime.now();
    final todayKey =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final isCompleted =
        (habit['completionHistory'] as Map<String, dynamic>)[todayKey] ?? false;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggleCompletion(todayKey);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isCompleted ? habit['color'] as Color : Colors.transparent,
          border: Border.all(
            color: habit['color'] as Color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: isCompleted
            ? CustomIconWidget(
                iconName: 'check',
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildCompletionGrid(BuildContext context) {
    final completionHistory =
        habit['completionHistory'] as Map<String, dynamic>;
    final today = DateTime.now();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(30, (index) {
          final date = today.subtract(Duration(days: 29 - index));
          final dateKey =
              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final isCompleted = completionHistory[dateKey] ?? false;
          final isToday = index == 29;

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onToggleCompletion(dateKey);
            },
            child: Container(
              margin: EdgeInsets.only(right: 1.w),
              child: Column(
                children: [
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight:
                              isToday ? FontWeight.w600 : FontWeight.w400,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                        ),
                  ),
                  SizedBox(height: 0.5.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? habit['color'] as Color
                          : Colors.transparent,
                      border: Border.all(
                        color: isToday
                            ? Theme.of(context).colorScheme.primary
                            : (habit['color'] as Color).withValues(alpha: 0.3),
                        width: isToday ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isCompleted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: Colors.white,
                            size: 12,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
