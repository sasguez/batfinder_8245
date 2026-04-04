import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class ChatService {
  // Get all chat rooms for current user
  static Future<List<Map<String, dynamic>>> getChatRooms() async {
    try {
      return await SupabaseService.getChatRooms();
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Get chat rooms error: $e');
      }
      return [];
    }
  }

  // Get messages for specific room
  static Future<List<Map<String, dynamic>>> getMessages(String roomId) async {
    try {
      return await SupabaseService.getChatMessages(roomId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Get messages error: $e');
      }
      return [];
    }
  }

  // Send message to room
  static Future<bool> sendMessage({
    required String roomId,
    required String message,
  }) async {
    try {
      await SupabaseService.sendMessage(roomId: roomId, message: message);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Send message error: $e');
      }
      return false;
    }
  }

  // Create new chat room (for incident-specific chats)
  static Future<String?> createChatRoom({
    required String roomName,
    String? incidentId,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('chat_rooms')
          .insert({'room_name': roomName, 'incident_id': incidentId})
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Create room error: $e');
      }
      return null;
    }
  }

  // Join chat room
  static Future<bool> joinChatRoom(String roomId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return false;

      await SupabaseService.client.from('chat_participants').insert({
        'room_id': roomId,
        'user_id': userId,
      });

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Join room error: $e');
      }
      return false;
    }
  }

  // Leave chat room
  static Future<bool> leaveChatRoom(String roomId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return false;

      await SupabaseService.client
          .from('chat_participants')
          .delete()
          .eq('room_id', roomId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Leave room error: $e');
      }
      return false;
    }
  }

  // Subscribe to real-time messages
  static RealtimeChannel subscribeToMessages(
    String roomId,
    Function(Map<String, dynamic>) onNewMessage,
  ) {
    return SupabaseService.subscribeToChatMessages(roomId, onNewMessage);
  }

  // Mark messages as read
  static Future<bool> markMessagesAsRead(String roomId) async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return false;

      await SupabaseService.client
          .from('chat_messages')
          .update({'is_read': true})
          .eq('room_id', roomId)
          .neq('sender_id', userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Mark as read error: $e');
      }
      return false;
    }
  }

  // Get unread message count
  static Future<int> getUnreadCount() async {
    try {
      final userId = SupabaseService.currentUserId;
      if (userId == null) return 0;

      final response = await SupabaseService.client
          .from('chat_messages')
          .select('id')
          .eq('is_read', false)
          .neq('sender_id', userId);

      return response.length;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ChatService: Get unread count error: $e');
      }
      return 0;
    }
  }
}