import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/incident_filter_sheet_widget.dart';
import './widgets/incident_marker_preview_widget.dart';
import './widgets/map_controls_widget.dart';
import './widgets/search_location_widget.dart';

class InteractiveSafetyMap extends StatefulWidget {
  const InteractiveSafetyMap({super.key});

  @override
  State<InteractiveSafetyMap> createState() => _InteractiveSafetyMapState();
}

class _InteractiveSafetyMapState extends State<InteractiveSafetyMap> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _isLoadingIncidents = false;
  bool _showHeatMap = false;
  bool _showSearchBar = false;
  MapType _currentMapType = MapType.normal;
  Set<Marker> _markers = {};
  String? _selectedIncidentId;
  RealtimeChannel? _incidentChannel;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  List<Map<String, dynamic>> _allIncidents = [];
  List<Map<String, dynamic>> _incidents = [];
  Map<String, dynamic> _activeFilters = {};

  // Bogotá como punto central por defecto (app colombiana)
  static const LatLng _defaultCenter = LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadIncidents();
    _subscribeToIncidents();
  }

  @override
  void dispose() {
    _incidentChannel?.unsubscribe();
    _mapController?.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> _loadIncidents() async {
    if (_isLoadingIncidents) return;
    setState(() => _isLoadingIncidents = true);
    try {
      final raw = await SupabaseService.getIncidents();
      if (mounted) {
        final normalized = raw.map(_normalizeIncident).toList();
        setState(() {
          _allIncidents = normalized;
          _incidents = _applyFilters(normalized, _activeFilters);
          _isLoadingIncidents = false;
        });
        _rebuildMarkers();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingIncidents = false);
    }
  }

  void _subscribeToIncidents() {
    _incidentChannel = SupabaseService.subscribeToIncidents((newRaw) {
      if (!mounted) return;
      final normalized = _normalizeIncident(newRaw);
      _allIncidents = [normalized, ..._allIncidents];
      setState(() => _incidents = _applyFilters(_allIncidents, _activeFilters));
      _rebuildMarkers();
    });
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> source,
    Map<String, dynamic> filters,
  ) {
    if (filters.isEmpty) return source;

    final selectedTypes = (filters['types'] as List?)?.cast<String>() ?? [];
    final selectedSeverities =
        (filters['severities'] as List?)?.cast<String>() ?? [];
    final timeRange = filters['timeRange'] as String? ?? '';

    final cutoff = _timeCutoff(timeRange);

    return source.where((inc) {
      if (selectedTypes.isNotEmpty &&
          !selectedTypes.contains(inc['incident_type_raw'] as String?)) {
        return false;
      }
      if (selectedSeverities.isNotEmpty &&
          !selectedSeverities.contains(inc['severity'] as String?)) {
        return false;
      }
      if (cutoff != null) {
        final ts = inc['timestamp'] as DateTime;
        if (ts.isBefore(cutoff)) return false;
      }
      return true;
    }).toList();
  }

  DateTime? _timeCutoff(String timeRange) {
    final now = DateTime.now();
    switch (timeRange) {
      case 'Última hora':      return now.subtract(const Duration(hours: 1));
      case 'Últimas 6 horas': return now.subtract(const Duration(hours: 6));
      case 'Últimas 24 horas': return now.subtract(const Duration(hours: 24));
      case 'Última semana':   return now.subtract(const Duration(days: 7));
      default:                return null;
    }
  }

  void _onFiltersApplied(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
      _incidents = _applyFilters(_allIncidents, filters);
      _selectedIncidentId = null;
    });
    _rebuildMarkers();
  }

  // Traduce la fila de Supabase al formato que esperan los widgets hijos.
  Map<String, dynamic> _normalizeIncident(Map<String, dynamic> raw) {
    final lat = (raw['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (raw['longitude'] as num?)?.toDouble() ?? 0.0;

    final reporter = raw['reporter'] as Map<String, dynamic>?;
    final isAnonymous = raw['is_anonymous'] as bool? ?? false;
    final reporterName = isAnonymous || reporter == null
        ? 'Ciudadano Anónimo'
        : (reporter['full_name'] as String? ?? 'Ciudadano Anónimo');
    final verified = reporter != null &&
        (reporter['verification_status'] as String?) == 'verified';

    DateTime timestamp;
    try {
      final rawDate = raw['created_at'] as String?;
      timestamp = rawDate != null ? DateTime.parse(rawDate) : DateTime.now();
    } catch (_) {
      timestamp = DateTime.now();
    }

    return {
      'id': raw['id'] as String? ?? '',
      'type': _localizeIncidentType(raw['incident_type'] as String? ?? 'other'),
      'incident_type_raw': raw['incident_type'] as String? ?? 'other',
      'severity': raw['severity'] as String? ?? 'low',
      'title': raw['title'] as String? ?? 'Sin título',
      'description': raw['description'] as String? ?? '',
      'location': {'lat': lat, 'lng': lng},
      'timestamp': timestamp,
      'status': raw['status'] as String? ?? 'active',
      'reporter': reporterName,
      'verified': verified,
    };
  }

  String _localizeIncidentType(String type) {
    switch (type) {
      case 'theft':      return 'Robo';
      case 'assault':    return 'Violencia';
      case 'vandalism':  return 'Vandalismo';
      case 'suspicious': return 'Actividad Sospechosa';
      case 'emergency':  return 'Emergencia';
      case 'other':      return 'Otro';
      default:           return 'Desconocido';
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
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
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _rebuildMarkers() {
    final Set<Marker> markers = {};
    for (final incident in _incidents) {
      final location = incident['location'] as Map<String, dynamic>;
      markers.add(
        Marker(
          markerId: MarkerId(incident['id'] as String),
          position: LatLng(
            (location['lat'] as num).toDouble(),
            (location['lng'] as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _severityHue(incident['severity'] as String),
          ),
          infoWindow: InfoWindow(
            title: incident['title'] as String,
            snippet: incident['type'] as String,
          ),
          onTap: () => _onMarkerTapped(incident['id'] as String),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  double _severityHue(String severity) {
    switch (severity) {
      case 'critical':
        return BitmapDescriptor.hueRed;
      case 'high':
        return BitmapDescriptor.hueOrange;
      case 'medium':
        return BitmapDescriptor.hueYellow;
      case 'low':
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onMapLongPress(LatLng position) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear Reporte de Incidente'),
        content: Text(
          '¿Desea crear un nuevo reporte en esta ubicación?\n\n'
          'Lat: ${position.latitude.toStringAsFixed(4)}\n'
          'Lng: ${position.longitude.toStringAsFixed(4)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushNamed('/incident-reporting');
            },
            child: const Text('Crear Reporte'),
          ),
        ],
      ),
    );
  }

  void _centerOnUserLocation() {
    if (_currentPosition == null) return;
    HapticFeedback.lightImpact();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        15.0,
      ),
    );
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
    final selectedIncident = _selectedIncidentId != null
        ? _incidents.cast<Map<String, dynamic>?>().firstWhere(
            (inc) => inc!['id'] == _selectedIncidentId,
            orElse: () => null,
          )
        : null;

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
              if (_isLoadingIncidents)
                Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              IconButton(
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                onPressed: _isLoadingIncidents ? null : _loadIncidents,
                tooltip: 'Actualizar',
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
                          const CircularProgressIndicator(),
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
                            : _defaultCenter,
                        zoom: 15.0,
                      ),
                      mapType: _currentMapType,
                      markers: _markers,
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
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
                          child: selectedIncident != null
                              ? IncidentMarkerPreviewWidget(
                                  incident: selectedIncident,
                                  scrollController: scrollController,
                                  onClose: () =>
                                      setState(() => _selectedIncidentId = null),
                                )
                              : IncidentFilterSheetWidget(
                                  scrollController: scrollController,
                                  incidents: _incidents,
                                  onFilterApplied: (filters) {
                                    HapticFeedback.lightImpact();
                                    _onFiltersApplied(filters);
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
