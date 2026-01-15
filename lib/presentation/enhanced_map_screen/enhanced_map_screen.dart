import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/map_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/incident_info_card_widget.dart';
import './widgets/map_filter_sheet_widget.dart';

class EnhancedMapScreen extends StatefulWidget {
  const EnhancedMapScreen({super.key});

  @override
  State<EnhancedMapScreen> createState() => _EnhancedMapScreenState();
}

class _EnhancedMapScreenState extends State<EnhancedMapScreen> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Position? _currentPosition;

  final Set<Marker> _markers = {};
  final Set<Circle> _hotspots = {};
  List<Map<String, dynamic>> _incidents = [];
  Map<String, dynamic>? _selectedIncident;

  bool _isLoading = true;
  bool _showHotspots = true;

  // Filter state
  List<String> _selectedTypes = [];
  List<String> _selectedSeverities = [];
  List<String> _selectedStatuses = [];

  static const CameraPosition _mexicoCityCenter = CameraPosition(
    target: LatLng(19.4326, -99.1332),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _loadIncidents();
    if (_showHotspots) {
      await _loadHotspots();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();

        if (_mapController != null && _currentPosition != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            ),
          );
        }
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  Future<void> _loadIncidents() async {
    try {
      setState(() => _isLoading = true);

      final incidents =
          _selectedTypes.isEmpty &&
              _selectedSeverities.isEmpty &&
              _selectedStatuses.isEmpty
          ? await _mapService.fetchIncidentsForMap()
          : await _mapService.fetchFilteredIncidents(
              types: _selectedTypes.isEmpty ? null : _selectedTypes,
              severities: _selectedSeverities.isEmpty
                  ? null
                  : _selectedSeverities,
              statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses,
            );

      setState(() {
        _incidents = incidents;
        _createMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar incidentes: $e')),
        );
      }
    }
  }

  Future<void> _loadHotspots() async {
    try {
      final hotspots = await _mapService.fetchHotspots();
      setState(() {
        _createHotspotCircles(hotspots);
      });
    } catch (e) {
      print('Error al cargar zonas críticas: $e');
    }
  }

  void _createMarkers() {
    _markers.clear();

    for (var incident in _incidents) {
      final markerId = MarkerId(incident['id']);
      final position = LatLng(
        incident['location_lat'],
        incident['location_lng'],
      );

      final marker = Marker(
        markerId: markerId,
        position: position,
        icon: _getMarkerIcon(incident['severity']),
        infoWindow: InfoWindow(
          title: incident['title'],
          snippet: incident['incident_type'],
        ),
        onTap: () => _onMarkerTapped(incident),
      );

      _markers.add(marker);
    }
  }

  BitmapDescriptor _getMarkerIcon(String severity) {
    switch (severity) {
      case 'critical':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case 'high':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'medium':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueYellow,
        );
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    }
  }

  void _createHotspotCircles(List<Map<String, dynamic>> hotspots) {
    _hotspots.clear();

    for (var hotspot in hotspots) {
      final circleId = CircleId(hotspot['id']);
      final center = LatLng(hotspot['location_lat'], hotspot['location_lng']);

      final circle = Circle(
        circleId: circleId,
        center: center,
        radius: hotspot['radius_meters'].toDouble(),
        fillColor: _getHotspotColor(hotspot['severity_score']),
        strokeColor: Colors.red.withAlpha(204),
        strokeWidth: 2,
      );

      _hotspots.add(circle);
    }
  }

  Color _getHotspotColor(dynamic severityScore) {
    final score = (severityScore as num).toDouble();
    if (score >= 70) return Colors.red.withAlpha(77);
    if (score >= 40) return Colors.orange.withAlpha(77);
    return Colors.yellow.withAlpha(77);
  }

  void _onMarkerTapped(Map<String, dynamic> incident) {
    setState(() {
      _selectedIncident = incident;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterSheetWidget(
        selectedTypes: _selectedTypes,
        selectedSeverities: _selectedSeverities,
        selectedStatuses: _selectedStatuses,
        onApplyFilters: (types, severities, statuses) {
          setState(() {
            _selectedTypes = types;
            _selectedSeverities = severities;
            _selectedStatuses = statuses;
          });
          _loadIncidents();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Mapa de Alertas',
        actions: [
          IconButton(
            icon: Icon(
              _showHotspots ? Icons.layers : Icons.layers_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showHotspots = !_showHotspots;
                if (_showHotspots) {
                  _loadHotspots();
                } else {
                  _hotspots.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                  ),
                );
              }
            },
            initialCameraPosition: _mexicoCityCenter,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            circles: _showHotspots ? _hotspots : {},
            mapType: MapType.normal,
            zoomControlsEnabled: false,
          ),

          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),

          if (_selectedIncident != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IncidentInfoCardWidget(
                incident: _selectedIncident!,
                onClose: () => setState(() => _selectedIncident = null),
                onViewDetails: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.alertDetails,
                    arguments: _selectedIncident!['id'],
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.incidentReporting);
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_alert, color: Colors.white),
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
