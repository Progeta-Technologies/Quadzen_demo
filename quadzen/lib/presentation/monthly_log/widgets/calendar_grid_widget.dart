import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CalendarGridWidget extends StatefulWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Map<DateTime, List<Map<String, dynamic>>> events;
  final Function(DateTime) onDateSelected;
  final bool isWeekView;
  final String searchQuery;

  const CalendarGridWidget({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.isWeekView,
    required this.searchQuery,
  });

  @override
  State<CalendarGridWidget> createState() => _CalendarGridWidgetState();
}

class _CalendarGridWidgetState extends State<CalendarGridWidget> {
  final List<String> _weekdays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];
  DateTime? _longPressedDate;

  List<DateTime> _getDaysInMonth() {
    final firstDay =
        DateTime(widget.currentMonth.year, widget.currentMonth.month, 1);
    final lastDay =
        DateTime(widget.currentMonth.year, widget.currentMonth.month + 1, 0);
    final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

    final days = <DateTime>[];
    for (int i = 0; i < 42; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  List<DateTime> _getDaysInWeek() {
    final startOfWeek = widget.selectedDate.subtract(
      Duration(days: widget.selectedDate.weekday % 7),
    );

    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(startOfWeek.add(Duration(days: i)));
    }
    return days;
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == widget.selectedDate.year &&
        date.month == widget.selectedDate.month &&
        date.day == widget.selectedDate.day;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == widget.currentMonth.month &&
        date.year == widget.currentMonth.year;
  }

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final dateKey = DateTime(date.year, date.month, date.day);
    final events = widget.events[dateKey] ?? [];

    if (widget.searchQuery.isEmpty) return events;

    return events.where((event) {
      final title = (event['title'] as String).toLowerCase();
      return title.contains(widget.searchQuery.toLowerCase());
    }).toList();
  }

  void _showContextMenu(DateTime date, Offset position) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'add',
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Add Event'),
            ],
          ),
          onTap: () {
            // Handle add event
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'edit',
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Edit Day'),
            ],
          ),
          onTap: () {
            // Handle edit day
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'copy',
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              SizedBox(width: 2.w),
              const Text('Copy Events'),
            ],
          ),
          onTap: () {
            // Handle copy events
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.isWeekView ? _getDaysInWeek() : _getDaysInMonth();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Column(
        children: [
          // Weekday headers
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h),
            child: Row(
              children: _weekdays
                  .map((weekday) => Expanded(
                        child: Text(
                          weekday,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Calendar grid
          Expanded(
            child: widget.isWeekView
                ? _buildWeekView(days)
                : _buildMonthView(days),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthView(List<DateTime> days) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        return _buildDateCell(date);
      },
    );
  }

  Widget _buildWeekView(List<DateTime> days) {
    return Column(
      children: days
          .map((date) => Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: _buildWeekDateCell(date),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDateCell(DateTime date) {
    final events = _getEventsForDate(date);
    final isToday = _isToday(date);
    final isSelected = _isSelected(date);
    final isCurrentMonth = _isCurrentMonth(date);

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      onLongPressStart: (details) {
        setState(() {
          _longPressedDate = date;
        });
        _showContextMenu(date, details.globalPosition);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : isToday
                  ? Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCurrentMonth
                        ? isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                    fontWeight: isToday || isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
            ),
            if (events.isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: events
                    .take(3)
                    .map((event) => Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: event['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                        ))
                    .toList(),
              ),
              if (events.length > 3)
                Text(
                  '+${events.length - 3}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 8.sp,
                      ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeekDateCell(DateTime date) {
    final events = _getEventsForDate(date);
    final isToday = _isToday(date);
    final isSelected = _isSelected(date);

    return GestureDetector(
      onTap: () => widget.onDateSelected(date),
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
              : Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdays[date.weekday % 7],
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: events.isEmpty
                  ? Text(
                      'No events',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: events
                          .take(2)
                          .map((event) => Container(
                                margin: EdgeInsets.only(bottom: 0.5.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: 0.5.h),
                                decoration: BoxDecoration(
                                  color: (event['color'] as Color)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: event['color'] as Color,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  event['title'] as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: event['color'] as Color,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
