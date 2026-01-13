import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying incident type badge, timestamp, and location information
class IncidentHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;

  const IncidentHeaderWidget({super.key, required this.alertData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String incidentType = alertData['type'] ?? 'Unknown';
    final DateTime timestamp = alertData['timestamp'] ?? DateTime.now();
    final String location = alertData['location'] ?? 'Unknown Location';
    final double distance = alertData['distance'] ?? 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getIncidentColor(incidentType, theme),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  incidentType.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Spacer(),
              CustomIconWidget(
                iconName: 'access_time',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${distance.toStringAsFixed(1)} km from your location',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIncidentColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'theft':
        return theme.colorScheme.error;
      case 'violence':
        return theme.colorScheme.primary;
      case 'suspicious activity':
        return Color(0xFFF57C00);
      case 'emergency':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.secondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
