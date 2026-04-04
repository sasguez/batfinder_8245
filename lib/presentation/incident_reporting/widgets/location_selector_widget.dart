import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for displaying and adjusting incident location
class LocationSelectorWidget extends StatelessWidget {
  final String locationText;
  final VoidCallback onAdjustLocation;
  final bool isLoadingLocation;

  const LocationSelectorWidget({
    super.key,
    required this.locationText,
    required this.onAdjustLocation,
    this.isLoadingLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ubicación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoadingLocation)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 1.5.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      locationText,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),
              Container(
                height: 15.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CustomIconWidget(
                        iconName: 'map',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 48,
                      ),
                    ),
                    Positioned(
                      bottom: 2.w,
                      right: 2.w,
                      child: ElevatedButton.icon(
                        onPressed: onAdjustLocation,
                        icon: CustomIconWidget(
                          iconName: 'edit_location',
                          color: theme.colorScheme.onPrimary,
                          size: 18,
                        ),
                        label: Text('Ajustar'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
