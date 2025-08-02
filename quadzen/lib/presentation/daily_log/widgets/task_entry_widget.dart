import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../models/task_model.dart';

class TaskEntryWidget extends StatelessWidget {
  final TaskModel task;
  final Function(TaskModel) onTaskUpdated;
  final VoidCallback onTaskDeleted;

  const TaskEntryWidget({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bullet Symbol
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: _getBulletColor(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                task.bulletSymbol,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),

          // Task Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  task.title,
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted
                        ? AppTheme.textMediumEmphasisLight
                        : AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),

                // Description
                if (task.description?.isNotEmpty == true) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    task.description!,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                    ),
                  ),
                ],

                // Tags
                if (task.tags.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 1.w,
                    children: task.tags
                        .map((tag) => Chip(
                              label: Text(
                                tag,
                                style: TextStyle(fontSize: 10.sp),
                              ),
                              backgroundColor: AppTheme
                                  .lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
                ],

                // Due Date
                if (task.dueDate != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14.sp,
                        color: task.isOverdue
                            ? AppTheme.lightTheme.colorScheme.error
                            : AppTheme.textMediumEmphasisLight,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        _formatDate(task.dueDate!),
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: task.isOverdue
                              ? AppTheme.lightTheme.colorScheme.error
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'toggle':
                  _toggleTaskCompletion();
                  break;
                case 'edit':
                  _editTask(context);
                  break;
                case 'delete':
                  _showDeleteConfirmation(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.radio_button_unchecked
                          : Icons.check_circle,
                      size: 18.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                        task.isCompleted ? 'Mark Incomplete' : 'Mark Complete'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18.sp),
                    SizedBox(width: 2.w),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete,
                        size: 18.sp,
                        color: AppTheme.lightTheme.colorScheme.error),
                    SizedBox(width: 2.w),
                    Text('Delete',
                        style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBulletColor() {
    switch (task.taskType) {
      case 'task':
        return task.isCompleted ? Colors.green : Colors.blue;
      case 'event':
        return Colors.orange;
      case 'note':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _toggleTaskCompletion() {
    final updatedTask = task.copyWith(
      status: task.isCompleted ? 'todo' : 'completed',
      completedAt: task.isCompleted ? null : DateTime.now(),
      updatedAt: DateTime.now(),
    );
    onTaskUpdated(updatedTask);
  }

  void _editTask(BuildContext context) {
    // TODO: Implement edit task functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit task functionality coming soon')),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onTaskDeleted();
            },
            child: Text('Delete',
                style: TextStyle(color: AppTheme.lightTheme.colorScheme.error)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (taskDate.isAtSameMomentAs(today.add(Duration(days: 1)))) {
      return 'Tomorrow';
    } else if (taskDate.isAtSameMomentAs(today.subtract(Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
