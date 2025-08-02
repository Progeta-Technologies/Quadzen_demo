import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './bullet_symbol_widget.dart';
import './course_card_widget.dart';
import './habit_grid_widget.dart';
import './mood_selector_widget.dart';

class OnboardingPageWidget extends StatelessWidget {
  final Map<String, dynamic> data;
  final int pageIndex;
  final VoidCallback onInteraction;

  const OnboardingPageWidget({
    super.key,
    required this.data,
    required this.pageIndex,
    required this.onInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 2.h),
          _buildIllustration(),
          SizedBox(height: 4.h),
          _buildTitle(),
          SizedBox(height: 2.h),
          _buildDescription(),
          SizedBox(height: 4.h),
          _buildInteractiveContent(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 80.w,
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomImageWidget(
          imageUrl: data["image"] as String,
          width: 80.w,
          height: 30.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      data["title"] as String,
      textAlign: TextAlign.center,
      style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      data["description"] as String,
      textAlign: TextAlign.center,
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      ),
    );
  }

  Widget _buildInteractiveContent() {
    switch (pageIndex) {
      case 0:
        return _buildBulletJournalDemo();
      case 1:
        return _buildHabitTrackingDemo();
      case 2:
        return _buildMoodTrackingDemo();
      case 3:
        return _buildAcademicPlanningDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBulletJournalDemo() {
    final features = data["features"] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapid Logging System',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          ...features.map((feature) => BulletSymbolWidget(
                symbol: feature["symbol"] as String,
                text: feature["text"] as String,
                iconName: feature["icon"] as String,
                onTap: onInteraction,
              )),
        ],
      ),
    );
  }

  Widget _buildHabitTrackingDemo() {
    final habits = data["habits"] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Habit Tracker',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          ...habits.map((habit) => HabitGridWidget(
                name: habit["name"] as String,
                streak: habit["streak"] as int,
                completed: habit["completed"] as bool,
                onTap: onInteraction,
              )),
        ],
      ),
    );
  }

  Widget _buildMoodTrackingDemo() {
    final moods = data["moods"] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling today?',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          MoodSelectorWidget(
            moods: moods,
            onMoodSelected: (mood) => onInteraction(),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicPlanningDemo() {
    final courses = data["courses"] as List<Map<String, dynamic>>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Courses',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 3.h),
          ...courses.map((course) => CourseCardWidget(
                name: course["name"] as String,
                grade: course["grade"] as String,
                assignments: course["assignments"] as int,
                onTap: onInteraction,
              )),
        ],
      ),
    );
  }
}
