import './supabase_service.dart';
import 'dart:math'; // Add this import

class MapService {
  final _supabase = SupabaseService.client;

  // Fetch all incidents for map display
  Future<List<Map<String, dynamic>>> fetchIncidentsForMap() async {
    try {
      final response = await _supabase
          .from('incidents')
          .select('''
            id,
            title,
            description,
            incident_type,
            severity,
            status,
            location_lat,
            location_lng,
            location_address,
            occurred_at,
            reported_at,
            is_anonymous,
            reporter_id,
            incident_media(id, media_url, media_type, caption)
          ''')
          .order('reported_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error al cargar incidentes para el mapa: $e');
    }
  }

  // Fetch incidents by filters
  Future<List<Map<String, dynamic>>> fetchFilteredIncidents({
    List<String>? types,
    List<String>? severities,
    List<String>? statuses,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.from('incidents').select('''
        id,
        title,
        description,
        incident_type,
        severity,
        status,
        location_lat,
        location_lng,
        location_address,
        occurred_at,
        reported_at,
        incident_media(id, media_url, media_type)
      ''');

      if (types != null && types.isNotEmpty) {
        query = query.inFilter('incident_type', types);
      }

      if (severities != null && severities.isNotEmpty) {
        query = query.inFilter('severity', severities);
      }

      if (statuses != null && statuses.isNotEmpty) {
        query = query.inFilter('status', statuses);
      }

      if (startDate != null) {
        query = query.gte('occurred_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('occurred_at', endDate.toIso8601String());
      }

      final response = await query.order('reported_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error al filtrar incidentes: $e');
    }
  }

  // Fetch hotspots for map visualization
  Future<List<Map<String, dynamic>>> fetchHotspots() async {
    try {
      final response = await _supabase
          .from('incident_hotspots')
          .select('*')
          .order('severity_score', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error al cargar zonas críticas: $e');
    }
  }

  // Fetch incidents near location
  Future<List<Map<String, dynamic>>> fetchNearbyIncidents(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      // Using PostGIS-like distance calculation (approximate)
      final response = await _supabase.rpc(
        'get_nearby_incidents',
        params: {'lat': latitude, 'lng': longitude, 'radius_km': radiusKm},
      );

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      // Fallback to fetch all and filter client-side
      final allIncidents = await fetchIncidentsForMap();
      return allIncidents.where((incident) {
        final incidentLat = incident['location_lat'] as double;
        final incidentLng = incident['location_lng'] as double;
        final distance = _calculateDistance(
          latitude,
          longitude,
          incidentLat,
          incidentLng,
        );
        return distance <= radiusKm;
      }).toList();
    }
  }

  // Calculate distance between two points (Haversine formula)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0; // km
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}