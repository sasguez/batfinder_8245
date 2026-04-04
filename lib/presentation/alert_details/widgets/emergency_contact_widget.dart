import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget providing quick access to Colombian emergency services
class EmergencyContactWidget extends StatelessWidget {
  const EmergencyContactWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.error, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emergency',
                color: theme.colorScheme.error,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Emergency Services',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          _buildEmergencyButton(
            context,
            'General Emergency',
            '123',
            Icons.phone,
            theme,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: _buildEmergencyButton(
                  context,
                  'Police',
                  '112',
                  Icons.local_police,
                  theme,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: _buildEmergencyButton(
                  context,
                  'Medical',
                  '125',
                  Icons.local_hospital,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(
    BuildContext context,
    String label,
    String number,
    IconData icon,
    ThemeData theme,
  ) {
    return ElevatedButton(
      onPressed: () => _callEmergency(context, number),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            number,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onError,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _callEmergency(BuildContext context, String number) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call Emergency Services'),
        content: Text('Do you want to call $number?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Calling $number...')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Call Now'),
          ),
        ],
      ),
    );
  }
}
