import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TaskSummaryCardWidget extends StatelessWidget {
  final int completed;
  final int total;
  final List<Map<String, dynamic>> tasks;
  final VoidCallback? onTap;

  const TaskSummaryCardWidget({
    Key? key,
    required this.completed,
    required this.total,
    required this.tasks,
    this.onTap,
  }) : super(key: key);

  double get _progress => total > 0 ? completed / total : 0.0;

  Color _getSymbolColor(String symbol) {
    switch (symbol) {
      case '•':
        return Colors.blue;
      case 'O':
        return Colors.green;
      case '–':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  width: 12.w,
                  height: 12.w,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 3,
                        backgroundColor: AppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${((_progress) * 100).round()}%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              '$completed of $total completed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: 2.h),
            if (tasks.isNotEmpty) ...[
              ...tasks.take(3).map((task) => Padding(
                    padding: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: _getSymbolColor(task["symbol"] as String)
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              task["symbol"] as String,
                              style: TextStyle(
                                color:
                                    _getSymbolColor(task["symbol"] as String),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            task["title"] as String,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  decoration: (task["completed"] as bool)
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: (task["completed"] as bool)
                                      ? Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.color
                                      : null,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task["completed"] as bool)
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: Colors.green,
                            size: 16,
                          ),
                      ],
                    ),
                  )),
              if (tasks.length > 3)
                Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text(
                    '+${tasks.length - 3} more tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                        ),
                  ),
                ),
            ] else
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'task_alt',
                      color: AppTheme.lightTheme.colorScheme.outline,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No tasks for today',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Tap + to add your first task',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
