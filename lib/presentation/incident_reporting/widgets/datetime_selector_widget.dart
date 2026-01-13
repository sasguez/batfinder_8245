import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for selecting date and time of incident
class DateTimeSelectorWidget extends StatelessWidget {
  final DateTime selectedDateTime;
  final Function(DateTime) onDateTimeChanged;

  const DateTimeSelectorWidget({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha y Hora',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${selectedDateTime.day.toString().padLeft(2, '0')}/${selectedDateTime.month.toString().padLeft(2, '0')}/${selectedDateTime.year}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          '${selectedDateTime.hour.toString().padLeft(2, '0')}:${selectedDateTime.minute.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(colorScheme: theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateTimeChanged(
        DateTime(
          picked.year,
          picked.month,
          picked.day,
          selectedDateTime.hour,
          selectedDateTime.minute,
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(colorScheme: theme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateTimeChanged(
        DateTime(
          selectedDateTime.year,
          selectedDateTime.month,
          selectedDateTime.day,
          picked.hour,
          picked.minute,
        ),
      );
    }
  }
}
