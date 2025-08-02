import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TaskMigrationWidget extends StatefulWidget {
  final List<Map<String, dynamic>> migrationTasks;
  final Function(int) onTaskMigrated;
  final Function(List<int>) onBulkMigration;

  const TaskMigrationWidget({
    super.key,
    required this.migrationTasks,
    required this.onTaskMigrated,
    required this.onBulkMigration,
  });

  @override
  State<TaskMigrationWidget> createState() => _TaskMigrationWidgetState();
}

class _TaskMigrationWidgetState extends State<TaskMigrationWidget> {
  bool _isSelectionMode = false;
  final Set<int> _selectedTasks = <int>{};

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTasks.clear();
      }
    });
  }

  void _toggleTaskSelection(int taskId) {
    setState(() {
      if (_selectedTasks.contains(taskId)) {
        _selectedTasks.remove(taskId);
      } else {
        _selectedTasks.add(taskId);
      }
    });
  }

  void _selectAllTasks() {
    setState(() {
      if (_selectedTasks.length == widget.migrationTasks.length) {
        _selectedTasks.clear();
      } else {
        _selectedTasks.clear();
        _selectedTasks.addAll(
          widget.migrationTasks.map((task) => task['id'] as int),
        );
      }
    });
  }

  void _migrateTasks() {
    if (_selectedTasks.isNotEmpty) {
      widget.onBulkMigration(_selectedTasks.toList());
      setState(() {
        _selectedTasks.clear();
        _isSelectionMode = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    const months = [
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.migrationTasks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: widget.migrationTasks.length,
            itemBuilder: (context, index) {
              final task = widget.migrationTasks[index];
              return _buildTaskItem(task, index);
            },
          ),
        ),
        if (_isSelectionMode) _buildSelectionActions(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'check_circle_outline',
            color: Theme.of(context).colorScheme.primary,
            size: 64,
          ),
          SizedBox(height: 3.h),
          Text(
            'All caught up!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'No tasks need migration.\nGreat job staying organized!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.all(4.w),
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CustomIconWidget(
                  iconName: 'insights',
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Productivity Insight',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'You\'ve completed 95% of your tasks this month. Keep up the excellent work!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task Migration',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${widget.migrationTasks.length} tasks need attention',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
          Row(
            children: [
              if (_isSelectionMode) ...[
                TextButton(
                  onPressed: _selectAllTasks,
                  child: Text(
                    _selectedTasks.length == widget.migrationTasks.length
                        ? 'Deselect All'
                        : 'Select All',
                  ),
                ),
                SizedBox(width: 2.w),
              ],
              IconButton(
                onPressed: _toggleSelectionMode,
                icon: CustomIconWidget(
                  iconName: _isSelectionMode ? 'close' : 'checklist',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: _isSelectionMode ? 'Exit Selection' : 'Bulk Select',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task, int index) {
    final taskId = task['id'] as int;
    final isSelected = _selectedTasks.contains(taskId);
    final originalDate = task['originalDate'] as DateTime;
    final priority = task['priority'] as String;

    return Dismissible(
      key: Key('task_$taskId'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'arrow_forward',
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Migrate',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        widget.onTaskMigrated(taskId);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) => _toggleTaskSelection(taskId),
                )
              : Container(
                  width: 4,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
          title: Text(
            task['title'] as String,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task['description'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  task['description'] as String,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.7),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 1.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(priority).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _getPriorityColor(priority),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'From ${_formatDate(originalDate)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                        ),
                  ),
                ],
              ),
            ],
          ),
          trailing: _isSelectionMode
              ? null
              : PopupMenuButton(
                  icon: CustomIconWidget(
                    iconName: 'more_vert',
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'edit',
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Edit'),
                        ],
                      ),
                      onTap: () {
                        // Handle edit task
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'arrow_forward',
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Migrate'),
                        ],
                      ),
                      onTap: () {
                        widget.onTaskMigrated(taskId);
                      },
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'delete',
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          const Text('Delete'),
                        ],
                      ),
                      onTap: () {
                        // Handle delete task
                      },
                    ),
                  ],
                ),
          onTap: _isSelectionMode
              ? () => _toggleTaskSelection(taskId)
              : () {
                  // Handle task tap - show details or edit
                },
        ),
      ),
    );
  }

  Widget _buildSelectionActions() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedTasks.length} selected',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _selectedTasks.isEmpty
                ? null
                : () {
                    // Handle bulk delete
                  },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          SizedBox(width: 2.w),
          ElevatedButton.icon(
            onPressed: _selectedTasks.isEmpty ? null : _migrateTasks,
            icon: CustomIconWidget(
              iconName: 'arrow_forward',
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18,
            ),
            label: const Text('Migrate'),
          ),
        ],
      ),
    );
  }
}
