import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Map Controls Widget
/// Provides floating controls for map interactions
class MapControlsWidget extends StatelessWidget {
  final bool showHeatMap;
  final MapType currentMapType;
  final VoidCallback onToggleHeatMap;
  final VoidCallback onToggleMapType;
  final VoidCallback onCenterLocation;

  const MapControlsWidget({
    super.key,
    required this.showHeatMap,
    required this.currentMapType,
    required this.onToggleHeatMap,
    required this.onToggleMapType,
    required this.onCenterLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onToggleHeatMap();
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: showHeatMap ? 'layers' : 'layers_clear',
                      color: showHeatMap
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Mapa de Calor',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: showHeatMap
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontWeight: showHeatMap
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onToggleMapType();
                  },
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: currentMapType == MapType.normal
                          ? 'satellite'
                          : 'map',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Divider(height: 1, thickness: 1),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onCenterLocation();
                  },
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'my_location',
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
