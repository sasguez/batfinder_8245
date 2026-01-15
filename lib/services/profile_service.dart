import './supabase_service.dart';
import 'dart:io';

class ProfileService {
  final _supabase = SupabaseService.client;

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      throw Exception('Error al obtener perfil: $e');
    }
  }

  // Create user profile (registration)
  Future<Map<String, dynamic>> createUserProfile({
    required String fullName,
    required String email,
    required String role,
    String? phoneNumber,
    String? organizationName,
    double? locationLat,
    double? locationLng,
    String? profileImageUrl,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final profileData = {
        'id': userId,
        'full_name': fullName,
        'email': email,
        'role': role,
        'phone_number': phoneNumber,
        'organization_name': organizationName,
        'location_lat': locationLat,
        'location_lng': locationLng,
        'profile_image_url': profileImageUrl,
        'is_verified': false,
        'verification_status': 'pending',
      };

      final response = await _supabase
          .from('user_profiles')
          .insert(profileData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Error al crear perfil: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? phoneNumber,
    String? organizationName,
    double? locationLat,
    double? locationLng,
    String? profileImageUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};

      if (fullName != null) updates['full_name'] = fullName;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (organizationName != null) {
        updates['organization_name'] = organizationName;
      }
      if (locationLat != null) updates['location_lat'] = locationLat;
      if (locationLng != null) updates['location_lng'] = locationLng;
      if (profileImageUrl != null) {
        updates['profile_image_url'] = profileImageUrl;
      }

      if (updates.isEmpty) {
        throw Exception('No hay cambios para actualizar');
      }

      final response = await _supabase
          .from('user_profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Get profile by user ID
  Future<Map<String, dynamic>?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  // Check if profile exists
  Future<bool> profileExists(String userId) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      final incidentsCount = await _supabase
          .from('incidents')
          .select('id')
          .eq('reporter_id', userId);

      final verifiedCount = await _supabase
          .from('incidents')
          .select('id')
          .eq('reporter_id', userId)
          .eq('status', 'verified');

      return {
        'total_incidents': incidentsCount.length,
        'verified_incidents': verifiedCount.length,
      };
    } catch (e) {
      return {'total_incidents': 0, 'verified_incidents': 0};
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(File imageFile) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuario no autenticado');
      }

      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_profile.${imageFile.path.split('.').last}';

      await _supabase.storage
          .from('profile-photos')
          .upload(fileName, imageFile);

      return fileName;
    } catch (e) {
      throw Exception('Error al subir foto: $e');
    }
  }

  // Get profile photo URL with signed URL for private bucket
  Future<String?> getProfilePhotoUrl(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return null;

    try {
      final signedUrl = await _supabase.storage
          .from('profile-photos')
          .createSignedUrl(filePath, 3600);
      return signedUrl;
    } catch (e) {
      return null;
    }
  }

  // Delete old profile photo
  Future<void> deleteProfilePhoto(String filePath) async {
    try {
      await _supabase.storage.from('profile-photos').remove([filePath]);
    } catch (e) {
      // Silently fail if photo doesn't exist
    }
  }
}
