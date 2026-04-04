import 'package:flutter/foundation.dart';

import './supabase_service.dart';

class AlertService {
  // Get alerts with filtering
  static Future<List<Map<String, dynamic>>> getAlerts({
    String? status,
    String? severity,
    String? incidentType,
    int limit = 50,
  }) async {
    try {
      return await SupabaseService.getIncidents(
        status: status,
        severity: severity,
        limit: limit,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Get alerts error: $e');
      }
      return [];
    }
  }

  // Get alert details
  static Future<Map<String, dynamic>?> getAlertDetails(String alertId) async {
    try {
      return await SupabaseService.getIncidentDetails(alertId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Get alert details error: $e');
      }
      return null;
    }
  }

  // Create new alert
  static Future<String?> createAlert({
    required String title,
    required String description,
    required String incidentType,
    required String severity,
    required double latitude,
    required double longitude,
    String? locationAddress,
    bool isAnonymous = false,
  }) async {
    try {
      return await SupabaseService.createIncident(
        title: title,
        description: description,
        incidentType: incidentType,
        severity: severity,
        latitude: latitude,
        longitude: longitude,
        locationAddress: locationAddress,
        isAnonymous: isAnonymous,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Create alert error: $e');
      }
      return null;
    }
  }

  // Update alert status (authority only)
  static Future<bool> updateAlertStatus({
    required String alertId,
    required String status,
  }) async {
    try {
      await SupabaseService.updateIncidentStatus(
        incidentId: alertId,
        status: status,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Update status error: $e');
      }
      return false;
    }
  }

  // Add comment to alert
  static Future<bool> addComment({
    required String alertId,
    required String comment,
  }) async {
    try {
      await SupabaseService.addIncidentComment(
        incidentId: alertId,
        comment: comment,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Add comment error: $e');
      }
      return false;
    }
  }

  // Get nearby alerts by location
  static Future<List<Map<String, dynamic>>> getNearbyAlerts({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final allAlerts = await getAlerts(status: 'active');

      // Filter alerts by distance (simplified - actual implementation would use PostGIS)
      return allAlerts.where((alert) {
        final alertLat = alert['latitude'] as double?;
        final alertLng = alert['longitude'] as double?;
        if (alertLat == null || alertLng == null) return false;

        // Simple distance calculation
        final distance = _calculateDistance(
          latitude,
          longitude,
          alertLat,
          alertLng,
        );
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AlertService: Get nearby alerts error: $e');
      }
      return [];
    }
  }

  // Helper function for distance calculation
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);

    final c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * Math.pi / 180;
  }

  // Subscribe to real-time alert updates
  static subscribeToAlerts(Function(Map<String, dynamic>) onNewAlert) {
    return SupabaseService.subscribeToIncidents(onNewAlert);
  }
}

// Math helper class
class Math {
  static const double pi = 3.14159265359;

  static double sin(double x) => x.sin();
  static double cos(double x) => x.cos();
  static double sqrt(double x) => x.sqrt();
  static double atan2(double y, double x) => y.atan2(x);
}

extension MathExtensions on double {
  double sin() => this * 1.0; // Simplified for demo
  double cos() => this * 1.0;
  double sqrt() => this * 1.0;
  double atan2(double x) => this / x;
}
