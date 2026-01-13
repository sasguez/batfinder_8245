import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/incident_filter_sheet_widget.dart';
import './widgets/incident_marker_preview_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/search_location_widget.dart';

/// Interactive Safety Map Screen
/// Provides real-time visualization of security incidents and safe zones
/// Tab bar navigation with Map tab active
class InteractiveSafetyMap extends StatefulWidget {
  const InteractiveSafetyMap({super.key});

  @override
  State<InteractiveSafetyMap> createState() => _InteractiveSafetyMapState();
}

class _InteractiveSafetyMapState extends State<InteractiveSafetyMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _showHeatMap = false;
  bool _showSearchBar = false;
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};
  Set<Circle> _geofencedZones = {};
  String? _selectedIncidentId;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // Mock incident data
  final List<Map<String, dynamic>> _incidents = [
    {
      "id": "INC001",
      "type": "Robo",
      "severity": "high",
      "title": "Robo a mano armada",
      "description": "Reporte de robo con arma de fuego en la zona comercial",
      "location": {"lat": 4.7110, "lng": -74.0721},
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "status": "active",
      "reporter": "Ciudadano Anónimo",
      "verified": true,
    },
    {
      "id": "INC002",
      "type": "Actividad Sospechosa",
      "severity": "medium",
      "title": "Persona sospechosa",
      "description": "Individuo merodeando vehículos estacionados",
      "location": {"lat": 4.7095, "lng": -74.0735},
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "status": "investigating",
      "reporter": "María González",
      "verified": false,
    },
    {
      "id": "INC003",
      "type": "Violencia",
      "severity": "critical",
      "title": "Altercado violento",
      "description": "Pelea con armas blancas reportada",
      "location": {"lat": 4.7125, "lng": -74.0710},
      "timestamp": DateTime.now().subtract(Duration(minutes: 45)),
      "status": "active",
      "reporter": "Carlos Ramírez",
      "verified": true,
    },
    {
      "id": "INC004",
      "type": "Robo",
      "severity": "low",
      "title": "Hurto de celular",
      "description": "Robo de dispositivo móvil sin violencia",
      "location": {"lat": 4.7080, "lng": -74.0745},
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "status": "resolved",
      "reporter": "Ana Martínez",
      "verified": true,
    },
  ];

  // Mock emergency services data
  final List<Map<String, dynamic>> _emergencyServices = [
    {
      "type": "police",
      "name": "Estación de Policía Centro",
      "location": {"lat": 4.7100, "lng": -74.0730},
      "phone": "123",
    },
    {
      "type": "hospital",
      "name": "Hospital San José",
      "location": {"lat": 4.7115, "lng": -74.0715},
      "phone": "125",
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeMarkers();
    _initializeGeofencedZones();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0,
        ),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _initializeMarkers() {
    Set<Marker> markers = {};

    for (var incident in _incidents) {
      final location = incident["location"] as Map<String, dynamic>;
      markers.add(
        Marker(
          markerId: MarkerId(incident["id"] as String),
          position: LatLng(
            (location["lat"] as num).toDouble(),
            (location["lng"] as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getSeverityColor(incident["severity"] as String),
          ),
          infoWindow: InfoWindow(
            title: incident["title"] as String,
            snippet: incident["type"] as String,
          ),
          onTap: () => _onMarkerTapped(incident["id"] as String),
        ),
      );
    }

    for (var service in _emergencyServices) {
      final location = service["location"] as Map<String, dynamic>;
      markers.add(
        Marker(
          markerId: MarkerId(service["name"] as String),
          position: LatLng(
            (location["lat"] as num).toDouble(),
            (location["lng"] as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            service["type"] == "police"
                ? BitmapDescriptor.hueBlue
                : BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: service["name"] as String,
            snippet: service["phone"] as String,
          ),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  void _initializeGeofencedZones() {
    Set<Circle> zones = {};

    zones.add(
      Circle(
        circleId: CircleId("zone_1"),
        center: LatLng(4.7110, -74.0721),
        radius: 500,
        fillColor: Colors.red.withValues(alpha: 0.2),
        strokeColor: Colors.red.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
    );

    zones.add(
      Circle(
        circleId: CircleId("zone_2"),
        center: LatLng(4.7095, -74.0735),
        radius: 300,
        fillColor: Colors.orange.withValues(alpha: 0.2),
        strokeColor: Colors.orange.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
    );

    setState(() => _geofencedZones = zones);
  }

  double _getSeverityColor(String severity) {
    switch (severity) {
      case "critical":
        return BitmapDescriptor.hueRed;
      case "high":
        return BitmapDescriptor.hueOrange;
      case "medium":
        return BitmapDescriptor.hueYellow;
      case "low":
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  void _onMarkerTapped(String incidentId) {
    HapticFeedback.lightImpact();
    setState(() => _selectedIncidentId = incidentId);
    _sheetController.animateTo(
      0.5,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onMapLongPress(LatLng position) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Crear Reporte de Incidente'),
        content: Text(
          '¿Desea crear un nuevo reporte en esta ubicación?\n\nLat: ${position.latitude.toStringAsFixed(4)}\nLng: ${position.longitude.toStringAsFixed(4)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed('/incident-reporting');
            },
            child: Text('Crear Reporte'),
          ),
        ],
      ),
    );
  }

  void _centerOnUserLocation() {
    if (_currentPosition != null) {
      HapticFeedback.lightImpact();
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        ),
      );
    }
  }

  void _toggleMapType() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _toggleHeatMap() {
    HapticFeedback.lightImpact();
    setState(() => _showHeatMap = !_showHeatMap);
  }

  void _toggleSearchBar() {
    HapticFeedback.lightImpact();
    setState(() => _showSearchBar = !_showSearchBar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 4.w,
            right: 4.w,
            bottom: 2.h,
          ),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Mapa de Seguridad',
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: _toggleSearchBar,
                tooltip: 'Buscar ubicación',
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _isLoadingLocation
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 2.h),
                          Text(
                            'Obteniendo ubicación...',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentPosition != null
                            ? LatLng(
                                _currentPosition!.latitude,
                                _currentPosition!.longitude,
                              )
                            : LatLng(4.7110, -74.0721),
                        zoom: 15.0,
                      ),
                      mapType: _currentMapType,
                      markers: _markers,
                      circles: _geofencedZones,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) => _mapController = controller,
                      onLongPress: _onMapLongPress,
                    ),
              if (_showSearchBar)
                Positioned(
                  top: 2.h,
                  left: 4.w,
                  right: 4.w,
                  child: SearchLocationWidget(
                    onLocationSelected: (LatLng position) {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLngZoom(position, 15.0),
                      );
                      setState(() => _showSearchBar = false);
                    },
                    onClose: () => setState(() => _showSearchBar = false),
                  ),
                ),
              Positioned(
                top: 2.h,
                left: 4.w,
                child: MapControlsWidget(
                  showHeatMap: _showHeatMap,
                  currentMapType: _currentMapType,
                  onToggleHeatMap: _toggleHeatMap,
                  onToggleMapType: _toggleMapType,
                  onCenterLocation: _centerOnUserLocation,
                ),
              ),
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.15,
                minChildSize: 0.15,
                maxChildSize: 0.8,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 12.w,
                          height: 0.5.h,
                          margin: EdgeInsets.symmetric(vertical: 1.h),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: _selectedIncidentId != null
                              ? IncidentMarkerPreviewWidget(
                                  incident: _incidents.firstWhere(
                                    (inc) => inc["id"] == _selectedIncidentId,
                                  ),
                                  scrollController: scrollController,
                                  onClose: () => setState(
                                    () => _selectedIncidentId = null,
                                  ),
                                )
                              : IncidentFilterSheetWidget(
                                  scrollController: scrollController,
                                  incidents: _incidents,
                                  onFilterApplied: (filters) {
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
