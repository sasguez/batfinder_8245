import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying incident location map with safe route suggestions
class IncidentMapWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;

  const IncidentMapWidget({super.key, required this.alertData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double latitude = alertData['latitude'] ?? 4.7110;
    final double longitude = alertData['longitude'] ?? -74.0721;

    return Container(
      height: 30.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'map',
                      color: theme.colorScheme.primary,
                      size: 48,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Incident Location',
                      style: theme.textTheme.titleMedium,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 2.h,
              right: 2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'route',
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Safe Route Available',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
