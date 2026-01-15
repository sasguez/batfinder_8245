import './supabase_service.dart';
import './offline_queue_service.dart';

class IncidentManagementService {
  final _supabase = SupabaseService.client;
  final _offlineQueue = OfflineQueueService();

  // Create new incident with offline support
  Future<Map<String, dynamic>> createIncident({
    required String title,
    required String description,
    required String incidentType,
    required String severity,
    required double locationLat,
    required double locationLng,
    String? locationAddress,
    required DateTime occurredAt,
    bool isAnonymous = false,
    List<String>? mediaUrls,
  }) async {
    try {
      final isOnline = await _offlineQueue.isOnline();

      if (!isOnline) {
        final localId = await _offlineQueue.queueIncident(
          title: title,
          description: description,
          incidentType: incidentType,
          severity: severity,
          locationLat: locationLat,
          locationLng: locationLng,
          locationAddress: locationAddress,
          occurredAt: occurredAt,
          isAnonymous: isAnonymous,
          mediaUrls: mediaUrls,
        );

        return {
          'id': localId,
          'title': title,
          'status': 'queued',
          'created_at': DateTime.now().toIso8601String(),
          'is_queued': true,
        };
      }

      final userId = _supabase.auth.currentUser?.id;
      if (userId == null && !isAnonymous) {
        throw Exception('Usuario no autenticado');
      }

      final incidentData = {
        'title': title,
        'description': description,
        'incident_type': incidentType,
        'severity': severity,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'location_address': locationAddress,
        'occurred_at': occurredAt.toIso8601String(),
        'is_anonymous': isAnonymous,
        'reporter_id': isAnonymous ? null : userId,
        'status': 'pending',
      };

      final response = await _supabase
          .from('incidents')
          .insert(incidentData)
          .select()
          .single();

      final incidentId = response['id'] as String;

      if (mediaUrls != null && mediaUrls.isNotEmpty) {
        await _addIncidentMedia(incidentId, mediaUrls);
      }

      return response;
    } catch (e) {
      final localId = await _offlineQueue.queueIncident(
        title: title,
        description: description,
        incidentType: incidentType,
        severity: severity,
        locationLat: locationLat,
        locationLng: locationLng,
        locationAddress: locationAddress,
        occurredAt: occurredAt,
        isAnonymous: isAnonymous,
        mediaUrls: mediaUrls,
      );

      return {
        'id': localId,
        'title': title,
        'status': 'queued',
        'created_at': DateTime.now().toIso8601String(),
        'is_queued': true,
      };
    }
  }

  // Update incident
  Future<Map<String, dynamic>> updateIncident({
    required String incidentId,
    String? title,
    String? description,
    String? severity,
    String? status,
    double? locationLat,
    double? locationLng,
    String? locationAddress,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (severity != null) updates['severity'] = severity;
      if (status != null) updates['status'] = status;
      if (locationLat != null) updates['location_lat'] = locationLat;
      if (locationLng != null) updates['location_lng'] = locationLng;
      if (locationAddress != null) {
        updates['location_address'] = locationAddress;
      }

      if (updates.isEmpty) {
        throw Exception('No hay cambios para actualizar');
      }

      final response = await _supabase
          .from('incidents')
          .update(updates)
          .eq('id', incidentId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Error al actualizar incidente: $e');
    }
  }

  // Delete incident (soft delete by changing status)
  Future<void> deleteIncident(String incidentId) async {
    try {
      await _supabase
          .from('incidents')
          .update({'status': 'rejected'})
          .eq('id', incidentId);
    } catch (e) {
      throw Exception('Error al eliminar incidente: $e');
    }
  }

  // Get incident by ID
  Future<Map<String, dynamic>?> getIncidentById(String incidentId) async {
    try {
      final response = await _supabase
          .from('incidents')
          .select('''
            *,
            incident_media(id, media_url, media_type, caption),
            user_profiles!reporter_id(full_name, profile_image_url)
          ''')
          .eq('id', incidentId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Get user's incidents
  Future<List<Map<String, dynamic>>> getUserIncidents(String userId) async {
    try {
      final response = await _supabase
          .from('incidents')
          .select('''
            id,
            title,
            incident_type,
            severity,
            status,
            location_address,
            occurred_at,
            reported_at
          ''')
          .eq('reporter_id', userId)
          .order('reported_at', ascending: false);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error al obtener incidentes del usuario: $e');
    }
  }

  // Add media to incident
  Future<void> _addIncidentMedia(
    String incidentId,
    List<String> mediaUrls,
  ) async {
    try {
      final mediaData = mediaUrls
          .map(
            (url) => {
              'incident_id': incidentId,
              'media_url': url,
              'media_type': url.contains('.mp4') || url.contains('.mov')
                  ? 'video'
                  : 'image',
            },
          )
          .toList();

      await _supabase.from('incident_media').insert(mediaData);
    } catch (e) {
      // Media addition is non-critical, log but don't throw
      print('Error al agregar medios: $e');
    }
  }

  // Add comment to incident
  Future<void> addComment({
    required String incidentId,
    required String commentText,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase.from('incident_comments').insert({
        'incident_id': incidentId,
        'user_id': userId,
        'comment_text': commentText,
      });
    } catch (e) {
      throw Exception('Error al agregar comentario: $e');
    }
  }

  // Get incident comments
  Future<List<Map<String, dynamic>>> getIncidentComments(
    String incidentId,
  ) async {
    try {
      final response = await _supabase
          .from('incident_comments')
          .select('''
            *,
            user_profiles(full_name, profile_image_url)
          ''')
          .eq('incident_id', incidentId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Error al obtener comentarios: $e');
    }
  }

  // Verify incident (authorities only)
  Future<void> verifyIncident(String incidentId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      await _supabase
          .from('incidents')
          .update({
            'status': 'verified',
            'verified_by': userId,
            'verified_at': DateTime.now().toIso8601String(),
          })
          .eq('id', incidentId);
    } catch (e) {
      throw Exception('Error al verificar incidente: $e');
    }
  }

  // Update incident status
  Future<void> updateIncidentStatus({
    required String incidentId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('incidents')
          .update({'status': status})
          .eq('id', incidentId);
    } catch (e) {
      throw Exception('Error al actualizar estado: $e');
    }
  }
}
