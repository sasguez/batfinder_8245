import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying related alerts in horizontal scrolling cards
class RelatedAlertsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> relatedAlerts;

  const RelatedAlertsWidget({super.key, required this.relatedAlerts});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (relatedAlerts.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Related Alerts in Area',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 18.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: relatedAlerts.length,
              separatorBuilder: (context, index) => SizedBox(width: 3.w),
              itemBuilder: (context, index) {
                final alert = relatedAlerts[index];
                return _buildRelatedAlertCard(context, alert, theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedAlertCard(
    BuildContext context,
    Map<String, dynamic> alert,
    ThemeData theme,
  ) {
    final String type = alert['type'] ?? 'Unknown';
    final String location = alert['location'] ?? 'Unknown';
    final DateTime timestamp = alert['timestamp'] ?? DateTime.now();
    final double distance = alert['distance'] ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).pushNamed('/alert-details');
      },
      child: Container(
        width: 60.w,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getIncidentColor(
                      type,
                      theme,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: _getIncidentColor(type, theme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  _formatTimestamp(timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'location_on',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.5.h),
            Text(
              '${distance.toStringAsFixed(1)} km away',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
