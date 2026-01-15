import 'package:flutter/foundation.dart';

import './supabase_service.dart';

class DashboardService {
  // Get dashboard statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      return await SupabaseService.getDashboardStatistics();
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get statistics error: $e');
      }
      return {
        'total_alerts': 0,
        'active_alerts': 0,
        'resolved_alerts': 0,
        'verified_alerts': 0,
      };
    }
  }

  // Get recent activity
  static Future<List<Map<String, dynamic>>> getRecentActivity({
    int limit = 10,
  }) async {
    try {
      return await SupabaseService.getRecentActivity(limit: limit);
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get recent activity error: $e');
      }
      return [];
    }
  }

  // Get safety score for area
  static Future<double> getSafetyScore({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final response = await SupabaseService.client.rpc(
        'calculate_safety_score',
        params: {'lat': latitude, 'lng': longitude, 'radius_km': radiusKm},
      );

      return (response as num?)?.toDouble() ?? 75.0;
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get safety score error: $e');
      }
      return 75.0; // Default safety score
    }
  }

  // Get incident statistics by type
  static Future<Map<String, int>> getIncidentsByType() async {
    try {
      final response = await SupabaseService.client
          .from('incidents')
          .select('incident_type');

      final Map<String, int> stats = {};
      for (var incident in response) {
        final type = incident['incident_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get incidents by type error: $e');
      }
      return {};
    }
  }

  // Get incident trends (last 7 days)
  static Future<List<Map<String, dynamic>>> getIncidentTrends() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final response = await SupabaseService.client
          .from('incidents')
          .select('created_at, severity')
          .gte('created_at', sevenDaysAgo.toIso8601String());

      final Map<String, int> dailyCounts = {};
      for (var incident in response) {
        final date = DateTime.parse(incident['created_at'] as String);
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        dailyCounts[dateKey] = (dailyCounts[dateKey] ?? 0) + 1;
      }

      return dailyCounts.entries
          .map((e) => {'date': e.key, 'count': e.value})
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get trends error: $e');
      }
      return [];
    }
  }

  // Get hotspot areas (areas with most incidents)
  static Future<List<Map<String, dynamic>>> getHotspots({int limit = 5}) async {
    try {
      final response = await SupabaseService.client.rpc(
        'get_incident_hotspots',
        params: {'result_limit': limit},
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get hotspots error: $e');
      }
      return [];
    }
  }

  // Get user contribution stats
  static Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final incidents = await SupabaseService.client
          .from('incidents')
          .select('id, status')
          .eq('reporter_id', userId);

      final resolved = incidents.where((i) => i['status'] == 'resolved').length;
      final pending = incidents.where((i) => i['status'] == 'pending').length;

      return {
        'total_reports': incidents.length,
        'resolved_reports': resolved,
        'pending_reports': pending,
        'contribution_score': (resolved * 10) + (pending * 5),
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService: Get user stats error: $e');
      }
      return {
        'total_reports': 0,
        'resolved_reports': 0,
        'pending_reports': 0,
        'contribution_score': 0,
      };
    }
  }
}
