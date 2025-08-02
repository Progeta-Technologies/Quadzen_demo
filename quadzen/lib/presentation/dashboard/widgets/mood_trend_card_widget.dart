import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MoodTrendCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> moodData;
  final VoidCallback? onTap;

  const MoodTrendCardWidget({
    Key? key,
    required this.moodData,
    this.onTap,
  }) : super(key: key);

  String _getMoodEmoji(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  Color _getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  double _getAverageMood() {
    if (moodData.isEmpty) return 0.0;
    final sum =
        moodData.fold<int>(0, (sum, mood) => sum + (mood["mood"] as int));
    return sum / moodData.length;
  }

  @override
  Widget build(BuildContext context) {
    final averageMood = _getAverageMood();

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
                  'Mood Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getMoodColor(averageMood.round())
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getMoodEmoji(averageMood.round()),
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${averageMood.toStringAsFixed(1)}/5',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getMoodColor(averageMood.round()),
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            if (moodData.isNotEmpty) ...[
              Container(
                height: 8.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: moodData.map((mood) {
                    final moodLevel = mood["mood"] as int;
                    final date = mood["date"] as String;
                    final height = (moodLevel / 5) * 6.h;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 6.w,
                          height: height,
                          decoration: BoxDecoration(
                            color: _getMoodColor(moodLevel),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          date,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'This week\'s average: ${averageMood.toStringAsFixed(1)}/5',
                style: Theme.of(context).textTheme.bodySmall,
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
                      iconName: 'mood',
                      color: AppTheme.lightTheme.colorScheme.outline,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'No mood data',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Start tracking your mood',
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
