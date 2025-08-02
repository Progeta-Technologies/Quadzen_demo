import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/calendar_grid_widget.dart';
import './widgets/month_header_widget.dart';
import './widgets/task_migration_widget.dart';

class MonthlyLog extends StatefulWidget {
  const MonthlyLog({super.key});

  @override
  State<MonthlyLog> createState() => _MonthlyLogState();
}

class _MonthlyLogState extends State<MonthlyLog> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime.now();
  bool _isWeekView = false;
  String _searchQuery = '';
  bool _isLoading = false;

  // Mock data for calendar events and tasks
  final Map<DateTime, List<Map<String, dynamic>>> _calendarEvents = {
    DateTime(2025, 7, 15): [
      {
        "id": 1,
        "title": "Complete Flutter project",
        "type": "task",
        "completed": false,
        "color": Colors.blue,
        "time": "10:00 AM"
      },
      {
        "id": 2,
        "title": "Team meeting",
        "type": "event",
        "color": Colors.green,
        "time": "2:00 PM"
      }
    ],
    DateTime(2025, 7, 20): [
      {
        "id": 3,
        "title": "Study session",
        "type": "task",
        "completed": true,
        "color": Colors.orange,
        "time": "9:00 AM"
      }
    ],
    DateTime(2025, 7, 25): [
      {
        "id": 4,
        "title": "Doctor appointment",
        "type": "event",
        "color": Colors.red,
        "time": "11:30 AM"
      }
    ]
  };

  final List<Map<String, dynamic>> _migrationTasks = [
    {
      "id": 1,
      "title": "Review quarterly goals",
      "originalDate": DateTime(2025, 6, 28),
      "type": "task",
      "priority": "high",
      "selected": false,
      "description": "Complete review of Q2 goals and set Q3 objectives"
    },
    {
      "id": 2,
      "title": "Update portfolio website",
      "originalDate": DateTime(2025, 6, 30),
      "type": "task",
      "priority": "medium",
      "selected": false,
      "description": "Add recent projects and update contact information"
    },
    {
      "id": 3,
      "title": "Call dentist for appointment",
      "originalDate": DateTime(2025, 7, 5),
      "type": "task",
      "priority": "low",
      "selected": false,
      "description": "Schedule routine cleaning appointment"
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _showDayDetailBottomSheet(date);
  }

  void _onMonthChanged(DateTime month) {
    setState(() {
      _currentMonth = month;
    });
  }

  void _toggleView() {
    setState(() {
      _isWeekView = !_isWeekView;
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  void _showDayDetailBottomSheet(DateTime date) {
    final events =
        _calendarEvents[DateTime(date.year, date.month, date.day)] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'event_available',
                            color: Colors.grey.withValues(alpha: 0.5),
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No events for this day',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 1.h),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              height: double.infinity,
                              color: event['color'] as Color,
                            ),
                            title: Text(
                              event['title'] as String,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              event['time'] as String,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: event['type'] == 'task'
                                ? Checkbox(
                                    value: event['completed'] as bool,
                                    onChanged: (value) {
                                      // Handle task completion
                                    },
                                  )
                                : CustomIconWidget(
                                    iconName: 'event',
                                    color: event['color'] as Color,
                                    size: 20,
                                  ),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle quick add
                    Navigator.pop(context);
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: const Text('Quick Add'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateEventModal() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Event Title',
                hintText: 'Enter event title',
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description (optional)',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle event creation
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Log'),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: _CalendarSearchDelegate(
                  onSearch: _onSearch,
                ),
              );
            },
            icon: CustomIconWidget(
              iconName: 'search',
              color: Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Calendar'),
            Tab(text: 'Migration'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Calendar Tab
            Column(
              children: [
                MonthHeaderWidget(
                  currentMonth: _currentMonth,
                  onMonthChanged: _onMonthChanged,
                  onTodayPressed: () {
                    setState(() {
                      _currentMonth = DateTime.now();
                      _selectedDate = DateTime.now();
                    });
                  },
                  onViewToggle: _toggleView,
                  isWeekView: _isWeekView,
                ),
                Expanded(
                  child: CalendarGridWidget(
                    currentMonth: _currentMonth,
                    selectedDate: _selectedDate,
                    events: _calendarEvents,
                    onDateSelected: _onDateSelected,
                    isWeekView: _isWeekView,
                    searchQuery: _searchQuery,
                  ),
                ),
              ],
            ),
            // Migration Tab
            TaskMigrationWidget(
              migrationTasks: _migrationTasks,
              onTaskMigrated: (taskId) {
                setState(() {
                  _migrationTasks.removeWhere((task) => task['id'] == taskId);
                });
              },
              onBulkMigration: (selectedTasks) {
                setState(() {
                  _migrationTasks.removeWhere(
                      (task) => selectedTasks.contains(task['id']));
                });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEventModal,
        child: CustomIconWidget(
          iconName: 'add',
          color: Theme.of(context).colorScheme.onSecondary,
          size: 24,
        ),
      ),
    );
  }
}

class _CalendarSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  _CalendarSearchDelegate({required this.onSearch});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          onSearch('');
        },
        icon: CustomIconWidget(
          iconName: 'clear',
          color: Theme.of(context).colorScheme.onSurface,
          size: 24,
        ),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: CustomIconWidget(
        iconName: 'arrow_back',
        color: Theme.of(context).colorScheme.onSurface,
        size: 24,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = [
      'tasks',
      'events',
      'meetings',
      'appointments',
      'deadlines',
    ];

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: CustomIconWidget(
            iconName: 'search',
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            onSearch(suggestion);
            close(context, suggestion);
          },
        );
      },
    );
  }
}
