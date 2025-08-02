import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class HabitGridWidget extends StatefulWidget {
  final String name;
  final int streak;
  final bool completed;
  final VoidCallback onTap;

  const HabitGridWidget({
    super.key,
    required this.name,
    required this.streak,
    required this.completed,
    required this.onTap,
  });

  @override
  State<HabitGridWidget> createState() => _HabitGridWidgetState();
}

class _HabitGridWidgetState extends State<HabitGridWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.completed;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    if (_isCompleted) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }

    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCompletion,
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: _isCompleted
              ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isCompleted
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 6.h,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: _isCompleted
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isCompleted
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: _isCompleted
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      decoration:
                          _isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'local_fire_department',
                        color: Colors.orange,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${widget.streak} day streak',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildWeeklyGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGrid() {
    return Row(
      children: List.generate(7, (index) {
        final isCompleted = index < widget.streak % 7 || widget.streak >= 7;
        return Container(
          margin: EdgeInsets.only(left: 0.5.w),
          width: 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
