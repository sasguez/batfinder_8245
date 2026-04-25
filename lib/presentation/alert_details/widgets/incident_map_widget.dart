import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class IncidentMapWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;

  const IncidentMapWidget({super.key, required this.alertData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double latitude =
        (alertData['latitude'] as num?)?.toDouble() ?? 4.7110;
    final double longitude =
        (alertData['longitude'] as num?)?.toDouble() ?? -74.0721;

    return Container(
      height: 28.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(latitude, longitude),
              zoom: 15.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('incident'),
                position: LatLng(latitude, longitude),
              ),
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            scrollGesturesEnabled: false,
            zoomGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
          ),
          Positioned(
            top: 1.5.h,
            left: 2.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: theme.colorScheme.error,
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Ubicación del incidente',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
