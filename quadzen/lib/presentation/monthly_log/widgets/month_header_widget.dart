import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MonthHeaderWidget extends StatelessWidget {
  final DateTime currentMonth;
  final Function(DateTime) onMonthChanged;
  final VoidCallback onTodayPressed;
  final VoidCallback onViewToggle;
  final bool isWeekView;

  const MonthHeaderWidget({
    super.key,
    required this.currentMonth,
    required this.onMonthChanged,
    required this.onTodayPressed,
    required this.onViewToggle,
    required this.isWeekView,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  final previousMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month - 1,
                  );
                  onMonthChanged(previousMonth);
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showMonthYearPicker(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: Column(
                      children: [
                        Text(
                          _getMonthName(currentMonth.month),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          currentMonth.year.toString(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  final nextMonth = DateTime(
                    currentMonth.year,
                    currentMonth.month + 1,
                  );
                  onMonthChanged(nextMonth);
                },
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: onTodayPressed,
                icon: CustomIconWidget(
                  iconName: 'today',
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                label: const Text('Today'),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onViewToggle,
                    icon: CustomIconWidget(
                      iconName: isWeekView ? 'calendar_month' : 'view_week',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                    tooltip: isWeekView ? 'Month View' : 'Week View',
                  ),
                  IconButton(
                    onPressed: () {
                      _showCalendarOptions(context);
                    },
                    icon: CustomIconWidget(
                      iconName: 'more_vert',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Month & Year'),
        content: SizedBox(
          width: 80.w,
          height: 40.h,
          child: Column(
            children: [
              // Year selector
              Container(
                height: 15.h,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 50,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final year = DateTime.now().year - 10 + index;
                      final isSelected = year == currentMonth.year;
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          year.toString(),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      );
                    },
                    childCount: 21,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Month selector
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isSelected = month == currentMonth.month;
                    return GestureDetector(
                      onTap: () {
                        final newDate = DateTime(currentMonth.year, month);
                        onMonthChanged(newDate);
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          _getMonthName(month).substring(0, 3),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCalendarOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'sync',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Sync Calendar'),
              subtitle: const Text('Sync with device calendar'),
              onTap: () {
                Navigator.pop(context);
                // Handle calendar sync
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'file_download',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Export Month'),
              subtitle: const Text('Export as PDF or Markdown'),
              onTap: () {
                Navigator.pop(context);
                // Handle export
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Calendar Settings'),
              subtitle: const Text('Customize calendar appearance'),
              onTap: () {
                Navigator.pop(context);
                // Handle settings
              },
            ),
          ],
        ),
      ),
    );
  }
}
