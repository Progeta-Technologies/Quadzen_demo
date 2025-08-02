import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/task_service.dart';
import '../../services/auth_service.dart';
import '../../models/task_model.dart';
import './widgets/task_entry_widget.dart';
import './widgets/rapid_logging_widget.dart';

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({Key? key}) : super(key: key);

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  DateTime _selectedDate = DateTime.now();
  List<TaskModel> _tasks = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (!(AuthService().isSignedIn)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await TaskService.getTasks(date: _selectedDate);
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to load tasks: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadTasks();
    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _addTask(String title, String type) async {
    if (!(AuthService().isSignedIn)) return;

    try {
      final task = TaskModel(
          id: '', // Will be set by database
          userId: AuthService().currentUserId ?? '',
          title: title,
          taskType: type,
          status: 'todo',
          priority: 1,
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());

      final createdTask = await TaskService.createTask(task);
      setState(() {
        _tasks.insert(0, createdTask);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add task: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _updateTask(TaskModel task) async {
    try {
      final updatedTask = await TaskService.updateTask(task);
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to update task: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      await TaskService.deleteTask(taskId);
      setState(() {
        _tasks.removeWhere((task) => task.id == taskId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to delete task: ${e.toString()}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error));
      }
    }
  }

  void _showRapidLoggingModal() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => RapidLoggingWidget(onTaskAdded: _addTask));
  }

  void _navigateToDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Daily Log'), centerTitle: true, actions: [
          IconButton(
              icon: Icon(Icons.today),
              onPressed: () => _navigateToDate(DateTime.now())),
        ]),
        body: Column(children: [
          // Date Header
          Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  border: Border(
                      bottom: BorderSide(
                          color: AppTheme.lightTheme.dividerColor,
                          width: 0.5))),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () => _navigateToDate(
                            _selectedDate.subtract(const Duration(days: 1)))),
                    Column(children: [
                      Text(_selectedDate.day.toString(),
                          style: AppTheme.lightTheme.textTheme.headlineLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary)),
                      Text(
                          '${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight)),
                      Text(_getDayName(_selectedDate.weekday),
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                  color: AppTheme.textMediumEmphasisLight)),
                    ]),
                    IconButton(
                        icon: Icon(Icons.arrow_forward_ios),
                        onPressed: () => _navigateToDate(
                            _selectedDate.add(const Duration(days: 1)))),
                  ])),

          // Tasks List
          Expanded(
              child: RefreshIndicator(
                  onRefresh: _refreshTasks,
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _tasks.isEmpty
                          ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                  Icon(Icons.note_add,
                                      size: 60,
                                      color: AppTheme.textMediumEmphasisLight),
                                  SizedBox(height: 2.h),
                                  Text('No entries for this date',
                                      style: AppTheme
                                          .lightTheme.textTheme.titleMedium
                                          ?.copyWith(
                                              color: AppTheme
                                                  .textMediumEmphasisLight)),
                                  SizedBox(height: 1.h),
                                  Text('Tap + to add your first entry',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                              color: AppTheme
                                                  .textMediumEmphasisLight)),
                                ]))
                          : ListView.builder(
                              padding: EdgeInsets.all(4.w),
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];
                                return TaskEntryWidget(
                                    task: task,
                                    onTaskUpdated: _updateTask,
                                    onTaskDeleted: () => _deleteTask(task.id));
                              }))),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: _showRapidLoggingModal, child: Icon(Icons.add)));
  }

  String _getMonthName(int month) {
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
      'December'
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
