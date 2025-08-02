import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MoodSelectorWidget extends StatefulWidget {
  final List<Map<String, dynamic>> moods;
  final Function(Map<String, dynamic>) onMoodSelected;

  const MoodSelectorWidget({
    super.key,
    required this.moods,
    required this.onMoodSelected,
  });

  @override
  State<MoodSelectorWidget> createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget>
    with TickerProviderStateMixin {
  int? _selectedMoodIndex;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      widget.moods.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 1.0,
        end: 1.2,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMood(int index) {
    setState(() {
      _selectedMoodIndex = index;
    });

    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });

    HapticFeedback.mediumImpact();
    widget.onMoodSelected(widget.moods[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.moods.length, (index) {
            final mood = widget.moods[index];
            final isSelected = _selectedMoodIndex == index;

            return GestureDetector(
              onTap: () => _selectMood(index),
              child: AnimatedBuilder(
                animation: _scaleAnimations[index],
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimations[index].value,
                    child: Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(mood["color"] as int).withValues(alpha: 0.2)
                            : AppTheme.lightTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Color(mood["color"] as int)
                              : AppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mood["emoji"] as String,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.moods.length, (index) {
            final mood = widget.moods[index];
            final isSelected = _selectedMoodIndex == index;

            return Text(
              mood["label"] as String,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? Color(mood["color"] as int)
                    : AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }),
        ),
        if (_selectedMoodIndex != null) ...[
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Color(widget.moods[_selectedMoodIndex!]["color"] as int)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(widget.moods[_selectedMoodIndex!]["color"] as int)
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'insights',
                  color:
                      Color(widget.moods[_selectedMoodIndex!]["color"] as int),
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Track your mood daily to identify patterns and improve your wellbeing',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
