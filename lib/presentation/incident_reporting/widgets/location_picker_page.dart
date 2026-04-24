import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

class LocationPickerPage extends StatefulWidget {
  final LatLng initialPosition;

  const LocationPickerPage({super.key, required this.initialPosition});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar Ubicación'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            child: Text(
              'Confirmar',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 16.0,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('selected'),
                position: _pickedLocation,
                draggable: true,
                onDragEnd: (pos) => setState(() => _pickedLocation = pos),
              ),
            },
            onTap: (pos) => setState(() => _pickedLocation = pos),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 3.h,
            left: 4.w,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'Toca el mapa o arrastra el marcador para ajustar la ubicación',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
