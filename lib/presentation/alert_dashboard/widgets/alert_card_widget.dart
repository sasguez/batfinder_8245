import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const AlertCardWidget({
    super.key,
    required this.alertData,
    required this.onTap,
    required this.onShare,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Slidable(
        key: ValueKey(alertData["id"]),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => onTap(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.info_outline,
              label: 'Details',
              borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            SlidableAction(
              onPressed: (context) => onShare(),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (alertData["severityColor"] as Color).withValues(
                    alpha: 0.3,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Alert icon
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: (alertData["severityColor"] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: alertData["icon"] as String,
                          color: alertData["severityColor"] as Color,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Alert type and timestamp
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alertData["type"] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  _formatTimestamp(
                                    alertData["timestamp"] as DateTime,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  alertData["distance"] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Severity indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: (alertData["severityColor"] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (alertData["severity"] as String).toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: alertData["severityColor"] as Color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Alert description
                  Text(
                    alertData["description"] as String,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // Alert location
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'place',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          alertData["location"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
