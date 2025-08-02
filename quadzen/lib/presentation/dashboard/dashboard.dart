import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/habit_streak_card_widget.dart';
import './widgets/mood_trend_card_widget.dart';
import './widgets/task_summary_card_widget.dart';
import './widgets/upcoming_events_card_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  bool _isRefreshing = false;

  // Mock data for dashboard
  final Map<String, dynamic> dashboardData = {
    "user": {
      "name": "Alex",
      "currentMood": "😊",
      "lastMoodUpdate": "2025-07-11T06:45:48.557051"
    },
    "todayTasks": {
      "completed": 8,
      "total": 12,
      "tasks": [
        {
          "id": 1,
          "title": "Review Flutter documentation",
          "type": "task",
          "completed": true,
          "symbol": "•"
        },
        {
          "id": 2,
          "title": "Complete math assignment",
          "type": "task",
          "completed": false,
          "symbol": "•"
        },
        {
          "id": 3,
          "title": "Team meeting at 3 PM",
          "type": "event",
          "completed": false,
          "symbol": "O"
        },
        {
          "id": 4,
          "title": "Remember to call mom",
          "type": "note",
          "completed": false,
          "symbol": "–"
        }
      ]
    },
    "upcomingEvents": [
      {
        "id": 1,
        "title": "Project Presentation",
        "time": "2:30 PM",
        "date": "Today",
        "location": "Room 204"
      },
      {
        "id": 2,
        "title": "Study Group",
        "time": "6:00 PM",
        "date": "Today",
        "location": "Library"
      },
      {
        "id": 3,
        "title": "Doctor Appointment",
        "time": "10:00 AM",
        "date": "Tomorrow",
        "location": "Medical Center"
      }
    ],
    "habitStreaks": [
      {
        "id": 1,
        "name": "Morning Exercise",
        "currentStreak": 7,
        "targetDays": 30,
        "completedToday": true,
        "icon": "fitness_center"
      },
      {
        "id": 2,
        "name": "Read 30 minutes",
        "currentStreak": 12,
        "targetDays": 21,
        "completedToday": false,
        "icon": "menu_book"
      },
      {
        "id": 3,
        "name": "Drink 8 glasses water",
        "currentStreak": 5,
        "targetDays": 14,
        "completedToday": true,
        "icon": "local_drink"
      }
    ],
    "moodTrend": [
      {"date": "Mon", "mood": 4},
      {"date": "Tue", "mood": 3},
      {"date": "Wed", "mood": 5},
      {"date": "Thu", "mood": 4},
      {"date": "Fri", "mood": 5},
      {"date": "Sat", "mood": 3},
      {"date": "Sun", "mood": 4}
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate network call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Stay on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/daily-log');
        break;
      case 2:
        Navigator.pushNamed(context, '/collections');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _showQuickTaskEntry() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Quick Entry',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                _buildQuickEntryButton('•', 'Task', Colors.blue),
                SizedBox(width: 3.w),
                _buildQuickEntryButton('O', 'Event', Colors.green),
                SizedBox(width: 3.w),
                _buildQuickEntryButton('–', 'Note', Colors.orange),
              ],
            ),
            SizedBox(height: 2.h),
            TextField(
              decoration: const InputDecoration(
                hintText: 'What would you like to add?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Add Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickEntryButton(String symbol, String label, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              symbol,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),
                GreetingHeaderWidget(
                  userName: dashboardData["user"]["name"] as String,
                  currentMood: dashboardData["user"]["currentMood"] as String,
                  onMoodTap: () {
                    // Navigate to mood tracker
                  },
                ),
                SizedBox(height: 3.h),
                TaskSummaryCardWidget(
                  completed: dashboardData["todayTasks"]["completed"] as int,
                  total: dashboardData["todayTasks"]["total"] as int,
                  tasks: (dashboardData["todayTasks"]["tasks"] as List)
                      .map((task) => task as Map<String, dynamic>)
                      .toList(),
                  onTap: () {
                    Navigator.pushNamed(context, '/daily-log');
                  },
                ),
                SizedBox(height: 2.h),
                UpcomingEventsCardWidget(
                  events: (dashboardData["upcomingEvents"] as List)
                      .map((event) => event as Map<String, dynamic>)
                      .toList(),
                  onTap: () {
                    Navigator.pushNamed(context, '/monthly-log');
                  },
                ),
                SizedBox(height: 2.h),
                HabitStreakCardWidget(
                  habits: (dashboardData["habitStreaks"] as List)
                      .map((habit) => habit as Map<String, dynamic>)
                      .toList(),
                  onTap: () {
                    Navigator.pushNamed(context, '/habit-tracker');
                  },
                ),
                SizedBox(height: 2.h),
                MoodTrendCardWidget(
                  moodData: (dashboardData["moodTrend"] as List)
                      .map((mood) => mood as Map<String, dynamic>)
                      .toList(),
                  onTap: () {
                    // Navigate to mood tracker
                  },
                ),
                SizedBox(height: 10.h), // Extra space for FAB
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickTaskEntry,
        child: CustomIconWidget(
          iconName: 'add',
          color: Theme.of(context).floatingActionButtonTheme.foregroundColor ??
              Colors.white,
          size: 24,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentIndex == 0
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'today',
              color: _currentIndex == 1
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 24,
            ),
            label: 'Daily Log',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'collections_bookmark',
              color: _currentIndex == 2
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 24,
            ),
            label: 'Collections',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor,
              size: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
