import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class HabitCreationModal extends StatefulWidget {
  final Map<String, dynamic>? habit;
  final Function(Map<String, dynamic>) onSave;

  const HabitCreationModal({
    super.key,
    this.habit,
    required this.onSave,
  });

  @override
  State<HabitCreationModal> createState() => _HabitCreationModalState();
}

class _HabitCreationModalState extends State<HabitCreationModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String _selectedFrequency = 'daily';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  String _selectedCategory = 'health';

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.cyan,
    Colors.pink,
    Colors.indigo,
    Colors.teal,
    Colors.amber,
  ];

  final List<String> _frequencies = ['daily', 'weekly', 'custom'];
  final List<String> _categories = [
    'health',
    'productivity',
    'learning',
    'wellness'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!['name'] as String;
      _selectedColor = widget.habit!['color'] as Color;
      _selectedFrequency = widget.habit!['frequency'] as String;
      _selectedCategory = widget.habit!['category'] as String;

      if (widget.habit!['reminderTime'] != null) {
        final timeParts = (widget.habit!['reminderTime'] as String).split(':');
        _reminderTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNameField(),
                    SizedBox(height: 3.h),
                    _buildColorPicker(),
                    SizedBox(height: 3.h),
                    _buildFrequencySelector(),
                    SizedBox(height: 3.h),
                    _buildCategorySelector(),
                    SizedBox(height: 3.h),
                    _buildReminderTimePicker(),
                    SizedBox(height: 4.h),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Expanded(
            child: Text(
              widget.habit != null ? 'Edit Habit' : 'Create Habit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: _saveHabit,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Name',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter habit name',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a habit name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.h,
          children: _availableColors.map((color) {
            final isSelected = color == _selectedColor;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: _frequencies.map((frequency) {
            final isSelected = frequency == _selectedFrequency;
            return ChoiceChip(
              label: Text(frequency.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFrequency = frequency;
                  });
                }
              },
              selectedColor: _selectedColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? _selectedColor : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          children: _categories.map((category) {
            final isSelected = category == _selectedCategory;
            return ChoiceChip(
              label: Text(category.toUpperCase()),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: _selectedColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? _selectedColor : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _selectReminderTime,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  _reminderTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveHabit,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
        child: Text(
          widget.habit != null ? 'Update Habit' : 'Create Habit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habitData = {
        'name': _nameController.text.trim(),
        'color': _selectedColor,
        'frequency': _selectedFrequency,
        'category': _selectedCategory,
        'reminderTime':
            '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
      };

      widget.onSave(habitData);
      Navigator.pop(context);
    }
  }
}
