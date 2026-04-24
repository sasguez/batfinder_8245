import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient? _client;

  // =============================
  // INITIALIZATION
  // =============================
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://wftraznajuzezwlfvuni.supabase.co',
        anonKey: 'sb_publishable_SPV0MouzJPWD3iPAsM3kww_W_WdgVlt',
      );
      _client = Supabase.instance.client;
      if (kDebugMode) print('✅ Supabase initialized successfully');
    } catch (e) {
      if (kDebugMode) print('❌ Supabase initialization error: $e');
      rethrow;
    }
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // =============================
  // AUTHENTICATION
  // =============================
  static Future<void> ensureUserProfile() async {
    final user = currentUser;
    if (user == null) return;

    final existing = await client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing == null) {
      await client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'full_name': user.userMetadata?['full_name'] ?? 'Usuario',
        'avatar_url': user.userMetadata?['avatar_url'],
      });
    }
  }

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await ensureUserProfile();
      return response;
    } catch (e) {
      if (kDebugMode) print('❌ Sign in error: $e');
      rethrow;
    }
  }

  static Future<void> signInWithGoogle() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
      await ensureUserProfile();
    } catch (e) {
      if (kDebugMode) print('❌ Google Sign-In error: $e');
      rethrow;
    }
  }

  static Future<void> signInWithFacebook() async {
    try {
      await client.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: 'io.supabase.flutter://login-callback',
      );
      await ensureUserProfile();
    } catch (e) {
      if (kDebugMode) print('❌ Facebook Sign-In error: $e');
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
      if (kDebugMode) print('❌ Sign up error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      if (kDebugMode) print('❌ Sign out error: $e');
      rethrow;
    }
  }

  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => client.auth.currentUser?.id;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  // =============================
  // USER PROFILE
  // =============================
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      return await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
    } catch (e) {
      if (kDebugMode) print('❌ Get user profile error: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client.from('users').update(updates).eq('id', userId);
    } catch (e) {
      if (kDebugMode) print('❌ Update profile error: $e');
      rethrow;
    }
  }

  // =============================
  // INCIDENTS
  // =============================
  static Future<List<Map<String, dynamic>>> getIncidents({
    String? status,
    String? severity,
    int limit = 50,
  }) async {
    try {
      var query = client.from('incidents').select('''
        *,
        reporter:users!incidents_reporter_id_fkey(
          full_name,
          avatar_url,
          verification_status
        ),
        incident_media(*)
      ''');

      if (status != null) query = query.eq('status', status);
      if (severity != null) query = query.eq('severity', severity);

      return await query
          .order('created_at', ascending: false)
          .limit(limit);
    } catch (e) {
      if (kDebugMode) print('❌ Get incidents error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getIncidentDetails(
    String incidentId,
  ) async {
    try {
      return await client.from('incidents').select('''
        *,
        reporter:users!incidents_reporter_id_fkey(
          full_name,
          avatar_url,
          verification_status,
          role
        ),
        incident_media(*),
        incident_comments(
          *,
          commenter:users(full_name, avatar_url)
        )
      ''').eq('id', incidentId).maybeSingle();
    } catch (e) {
      if (kDebugMode) print('❌ Get incident details error: $e');
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
            'latitude': latitude,
            'longitude': longitude,
            'location_address': locationAddress,
            'is_anonymous': isAnonymous,
            'status': 'active',
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) print('❌ Create incident error: $e');
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
      if (kDebugMode) print('❌ Update incident status error: $e');
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
      if (kDebugMode) print('❌ Add comment error: $e');
      rethrow;
    }
  }

  // =============================
  // CHAT
  // =============================
  static Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      return await client
          .from('chat_participants')
          .select('''
            chat_room_id,
            chat_rooms(
              *,
              last_message:chat_messages(message, created_at)
            )
          ''')
          .eq('user_id', userId)
          .order('joined_at', ascending: false);
    } catch (e) {
      if (kDebugMode) print('❌ Get chat rooms error: $e');
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
            sender:users(full_name, avatar_url, role)
          ''')
          .eq('room_id', roomId)
          .order('created_at', ascending: true);
    } catch (e) {
      if (kDebugMode) print('❌ Get messages error: $e');
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
      if (kDebugMode) print('❌ Send message error: $e');
      rethrow;
    }
  }

  // =============================
  // REALTIME
  // =============================
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

  // =============================
  // STATISTICS
  // =============================
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
      if (kDebugMode) print('❌ Get statistics error: $e');
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
            user:users(full_name, avatar_url)
          ''')
          .order('timestamp', ascending: false)
          .limit(limit);
    } catch (e) {
      if (kDebugMode) print('❌ Get recent activity error: $e');
      return [];
    }
  }

  // =============================
  // EMERGENCY CONTACTS
  // =============================
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];

      return await client
          .from('emergency_contacts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);
    } catch (e) {
      if (kDebugMode) print('❌ Get emergency contacts error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addEmergencyContact({
    required String name,
    required String phone,
    String relation = '',
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      return await client
          .from('emergency_contacts')
          .insert({
            'user_id': userId,
            'name': name,
            'phone': phone,
            'relation': relation,
          })
          .select()
          .single();
    } catch (e) {
      if (kDebugMode) print('❌ Add emergency contact error: $e');
      rethrow;
    }
  }

  static Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await client.from('emergency_contacts').delete().eq('id', contactId);
    } catch (e) {
      if (kDebugMode) print('❌ Delete emergency contact error: $e');
      rethrow;
    }
  }

  // =============================
  // EMERGENCY ALERTS (PANIC)
  // =============================
  static Future<String?> createEmergencyAlert({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final response = await client
          .from('emergency_alerts')
          .insert({
            'user_id': userId,
            'latitude': latitude,
            'longitude': longitude,
            'status': 'active',
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) print('❌ Create emergency alert error: $e');
      return null;
    }
  }

  static Future<void> resolveEmergencyAlert(String alertId) async {
    try {
      await client.from('emergency_alerts').update({
        'status': 'resolved',
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', alertId);
    } catch (e) {
      if (kDebugMode) print('❌ Resolve emergency alert error: $e');
      rethrow;
    }
  }

  static Future<void> cancelEmergencyAlert(String alertId) async {
    try {
      await client.from('emergency_alerts').update({
        'status': 'cancelled',
        'resolved_at': DateTime.now().toIso8601String(),
      }).eq('id', alertId);
    } catch (e) {
      if (kDebugMode) print('❌ Cancel emergency alert error: $e');
      rethrow;
    }
  }
}
