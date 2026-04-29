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
      if (kDebugMode) print('âœ… Supabase initialized successfully');
    } catch (e) {
      if (kDebugMode) print('âŒ Supabase initialization error: $e');
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
      if (kDebugMode) print('âŒ Sign in error: $e');
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
      if (kDebugMode) print('âŒ Google Sign-In error: $e');
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
      if (kDebugMode) print('âŒ Facebook Sign-In error: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      await ensureUserProfile();
      return response;
    } catch (e) {
      if (kDebugMode) print('âŒ Sign up error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      if (kDebugMode) print('âŒ Sign out error: $e');
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
      if (kDebugMode) print('âŒ Get user profile error: $e');
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
      if (kDebugMode) print('âŒ Update profile error: $e');
      rethrow;
    }
  }

  static Future<String?> uploadAvatar(String userId, Uint8List bytes) async {
    try {
      final fileName = '$userId/avatar.jpg';
      await client.storage.from('avatars').uploadBinary(
        fileName,
        bytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      final url = client.storage.from('avatars').getPublicUrl(fileName);
      await updateUserProfile(userId: userId, updates: {'avatar_url': url});
      return url;
    } catch (e) {
      if (kDebugMode) print('âŒ Upload avatar error: $e');
      return null;
    }
  }

  static bool get isGoogleUser {
    final provider = currentUser?.appMetadata['provider'] as String? ?? '';
    return provider == 'google';
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
      if (kDebugMode) print('âŒ Get incidents error: $e');
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
      if (kDebugMode) print('âŒ Get incident details error: $e');
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
      if (kDebugMode) print('âŒ Create incident error: $e');
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
      if (kDebugMode) print('âŒ Update incident status error: $e');
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
      if (kDebugMode) print('âŒ Add comment error: $e');
      rethrow;
    }
  }

  // =============================
  // CHAT
  // =============================
  /*
  static Future<List<Map<String, dynamic>>> getAllChatRooms() async {
    try {
      return await client
          .from('chat_rooms')
          .select()
          .limit(50);
    } catch (e) {
      if (kDebugMode) print('âŒ Get all chat rooms error: $e');
      return [];
    }
  }

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
      if (kDebugMode) print('âŒ Get chat rooms error: $e');
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
      if (kDebugMode) print('âŒ Get messages error: $e');
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
      if (kDebugMode) print('âŒ Send message error: $e');
      rethrow;
    }
  }
  */

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

  /*
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
  */

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
      if (kDebugMode) print('âŒ Get statistics error: $e');
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
      if (kDebugMode) print('âŒ Get recent activity error: $e');
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
      if (kDebugMode) print('âŒ Get emergency contacts error: $e');
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
      if (kDebugMode) print('âŒ Add emergency contact error: $e');
      rethrow;
    }
  }

  static Future<void> deleteEmergencyContact(String contactId) async {
    try {
      await client.from('emergency_contacts').delete().eq('id', contactId);
    } catch (e) {
      if (kDebugMode) print('âŒ Delete emergency contact error: $e');
      rethrow;
    }
  }

  // Esquema extendido: phone_wa, phone_sms, has_app, fcm_token, priority, whatsapp_optin
  static Future<List<Map<String, dynamic>>> getEmergencyContactsFull() async {
    try {
      final userId = currentUserId;
      if (userId == null) return [];
      return await client
          .from('emergency_contacts')
          .select()
          .eq('user_id', userId)
          .order('priority', ascending: true)
          .order('created_at', ascending: true);
    } catch (e) {
      if (kDebugMode) print('âŒ getEmergencyContactsFull error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addEmergencyContactFull({
    required String name,
    String? phoneWa,
    String? phoneSms,
    bool hasApp = false,
    String? fcmToken,
    int priority = 1,
    bool whatsappOptin = false,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception('User not authenticated');
      return await client
          .from('emergency_contacts')
          .insert({
            'user_id':        userId,
            'name':           name,
            'phone_wa':       phoneWa,
            'phone':          phoneWa ?? phoneSms ?? '',
            'phone_sms':      phoneSms,
            'has_app':        hasApp,
            'fcm_token':      fcmToken,
            'priority':       priority,
            'whatsapp_optin': whatsappOptin,
          })
          .select()
          .single();
    } catch (e) {
      if (kDebugMode) print('âŒ addEmergencyContactFull error: $e');
      rethrow;
    }
  }

  static Future<void> updateEmergencyContactFull({
    required String contactId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await client
          .from('emergency_contacts')
          .update(updates)
          .eq('id', contactId);
    } catch (e) {
      if (kDebugMode) print('âŒ updateEmergencyContactFull error: $e');
      rethrow;
    }
  }

  // Registra el FCM token del dispositivo actual en el perfil del usuario
  // Requiere columna fcm_token en la tabla users
  static Future<void> registerFCMToken(String token) async {
    final userId = currentUserId;
    if (userId == null) return;
    try {
      await client.from('users').update({'fcm_token': token}).eq('id', userId);
      if (kDebugMode) print('âœ… FCM token registrado');
    } catch (e) {
      if (kDebugMode) print('âŒ registerFCMToken error: $e');
    }
  }

  // Busca el FCM token de otro usuario por email para guardarlo en emergency_contacts
  static Future<String?> lookupContactFCMToken(String email) async {
    try {
      final result = await client
          .from('users')
          .select('fcm_token')
          .eq('email', email.trim().toLowerCase())
          .maybeSingle();
      return result?['fcm_token'] as String?;
    } catch (e) {
      if (kDebugMode) print('âŒ lookupContactFCMToken error: $e');
      return null;
    }
  }

  // Verifica si un nickname esta disponible para el usuario actual
  static Future<bool> checkNicknameAvailable(String nickname) async {
    try {
      final result = await client
          .from('users')
          .select('id')
          .eq('nickname', nickname.toLowerCase().trim())
          .neq('id', currentUserId ?? '')
          .maybeSingle();
      return result == null;
    } catch (e) {
      if (kDebugMode) print('checkNicknameAvailable error: $e');
      return false;
    }
  }

  // Busca un usuario por @nickname, email o telefono para obtener su FCM token
  static Future<Map<String, dynamic>?> lookupUserForFCM(String query) async {
    final trimmed = query.trim();
    try {
      if (trimmed.startsWith('@')) {
        final nickname = trimmed.substring(1).toLowerCase();
        return await client
            .from('users')
            .select('full_name, nickname, fcm_token')
            .eq('nickname', nickname)
            .maybeSingle();
      } else if (trimmed.contains('@')) {
        return await client
            .from('users')
            .select('full_name, nickname, fcm_token')
            .eq('email', trimmed.toLowerCase())
            .maybeSingle();
      } else {
        final phone = trimmed.replaceAll(' ', '').replaceAll('-', '');
        return await client
            .from('users')
            .select('full_name, nickname, fcm_token')
            .eq('phone', phone)
            .maybeSingle();
      }
    } catch (e) {
      if (kDebugMode) print('lookupUserForFCM error: $e');
      return null;
    }
  }

  // Verifica si el usuario tiene al menos un contacto con canal de notificaciÃ³n vÃ¡lido
  static Future<bool> hasValidEmergencyContacts() async {
    final userId = currentUserId;
    if (userId == null) return false;
    try {
      final contacts = await client
          .from('emergency_contacts')
          .select('phone_wa, whatsapp_optin, has_app, fcm_token')
          .eq('user_id', userId);
      return (contacts as List).any((c) =>
          (c['whatsapp_optin'] == true &&
              (c['phone_wa'] as String?)?.isNotEmpty == true) ||
          (c['has_app'] == true &&
              (c['fcm_token'] as String?)?.isNotEmpty == true));
    } catch (e) {
      if (kDebugMode) print('âŒ hasValidEmergencyContacts error: $e');
      return false;
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
      if (kDebugMode) print('âŒ Create emergency alert error: $e');
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
      if (kDebugMode) print('âŒ Resolve emergency alert error: $e');
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
      if (kDebugMode) print('âŒ Cancel emergency alert error: $e');
      rethrow;
    }
  }

  // =============================
  // EMAIL VERIFICATION
  // =============================
  static Future<void> resendVerificationEmail(String email) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      if (kDebugMode) print('âŒ Resend verification email error: $e');
      rethrow;
    }
  }
}
