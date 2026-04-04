import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: const String.fromEnvironment('SUPABASE_URL'),
        anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
      );
      _client = Supabase.instance.client;
      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Supabase initialization error: $e');
      }
      rethrow;
    }
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Authentication Methods
  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in error: $e');
      }
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      return await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign up error: $e');
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out error: $e');
      }
      rethrow;
    }
  }

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => client.auth.currentUser?.id;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // User Profile Methods
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get user profile error: $e');
      }
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client.from('user_profiles').update(updates).eq('user_id', userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update profile error: $e');
      }
      rethrow;
    }
  }

  // Incident Methods
  static Future<List<Map<String, dynamic>>> getIncidents({
    String? status,
    String? severity,
    int limit = 50,
  }) async {
    try {
      var query = client.from('incidents').select('''
            *,
            reporter:user_profiles!incidents_reporter_id_fkey(
              full_name,
              avatar_url,
              verification_status
            ),
            incident_media(*)
          ''');

      // Apply filters before ordering and limit
      if (status != null) {
        query = query.eq('status', status);
      }
      if (severity != null) {
        query = query.eq('severity', severity);
      }

      // Apply ordering and limit after filters
      final result = query.order('created_at', ascending: false).limit(limit);

      return await result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get incidents error: $e');
      }
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getIncidentDetails(
    String incidentId,
  ) async {
    try {
      final response = await client
          .from('incidents')
          .select('''
            *,
            reporter:user_profiles!incidents_reporter_id_fkey(
              full_name,
              avatar_url,
              verification_status,
              role
            ),
            incident_media(*),
            incident_comments(
              *,
              commenter:user_profiles(full_name, avatar_url)
            )
          ''')
          .eq('id', incidentId)
          .maybeSingle();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get incident details error: $e');
      }
      return null;
    }
  }

  static Future<String> createIncident({
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
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await client
          .from('incidents')
          .insert({
            'reporter_id': userId,
            'title': title,
            'description': description,
            'incident_type': incidentType,
            'severity': severity,
            'location': 'POINT($longitude $latitude)',
            'location_address': locationAddress,
            'is_anonymous': isAnonymous,
            'status': 'pending',
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Create incident error: $e');
      }
      rethrow;
    }
  }

  static Future<void> updateIncidentStatus({
    required String incidentId,
    required String status,
  }) async {
    try {
      await client
          .from('incidents')
          .update({'status': status})
          .eq('id', incidentId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Update incident status error: $e');
      }
      rethrow;
    }
  }

  static Future<void> addIncidentComment({
    required String incidentId,
    required String comment,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await client.from('incident_comments').insert({
        'incident_id': incidentId,
        'commenter_id': userId,
        'comment': comment,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Add comment error: $e');
      }
      rethrow;
    }
  }

  // Chat Methods
  static Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      final response = await client
          .from('chat_participants')
          .select('''
            chat_room_id,
            chat_rooms(
              *,
              last_message:chat_messages(
                message,
                created_at
              )
            )
          ''')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get chat rooms error: $e');
      }
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getChatMessages(
    String roomId,
  ) async {
    try {
      return await client
          .from('chat_messages')
          .select('''
            *,
            sender:user_profiles(
              full_name,
              avatar_url,
              role
            )
          ''')
          .eq('room_id', roomId)
          .order('created_at', ascending: true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get messages error: $e');
      }
      return [];
    }
  }

  static Future<void> sendMessage({
    required String roomId,
    required String message,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      await client.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': userId,
        'message': message,
      });
    } catch (e) {
      if (kDebugMode) {
        print('❌ Send message error: $e');
      }
      rethrow;
    }
  }

  // Real-time Subscriptions
  static RealtimeChannel subscribeToIncidents(
    Function(Map<String, dynamic>) onIncident,
  ) {
    return client
        .channel('incidents_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'incidents',
          callback: (payload) => onIncident(payload.newRecord),
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToChatMessages(
    String roomId,
    Function(Map<String, dynamic>) onMessage,
  ) {
    return client
        .channel('chat_$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) => onMessage(payload.newRecord),
        )
        .subscribe();
  }

  // Statistics Methods
  static Future<Map<String, dynamic>> getDashboardStatistics() async {
    try {
      final response = await client
          .from('alert_statistics')
          .select()
          .order('date', ascending: false)
          .limit(1)
          .maybeSingle();

      return response ??
          {
            'total_alerts': 0,
            'active_alerts': 0,
            'resolved_alerts': 0,
            'verified_alerts': 0,
          };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get statistics error: $e');
      }
      return {
        'total_alerts': 0,
        'active_alerts': 0,
        'resolved_alerts': 0,
        'verified_alerts': 0,
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getRecentActivity({
    int limit = 10,
  }) async {
    try {
      return await client
          .from('user_activity_logs')
          .select('''
            *,
            user:user_profiles(full_name, avatar_url)
          ''')
          .order('timestamp', ascending: false)
          .limit(limit);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Get recent activity error: $e');
      }
      return [];
    }
  }
}