import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_list_item_widget.dart';
import './widgets/chat_message_widget.dart';

class CommunitySafetyChat extends StatefulWidget {
  const CommunitySafetyChat({super.key});

  @override
  State<CommunitySafetyChat> createState() => _CommunitySafetyChatState();
}

class _CommunitySafetyChatState extends State<CommunitySafetyChat> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String? _selectedChatId;
  String? _selectedChatName;
  bool _isTyping = false;
  bool _isLoadingRooms = true;
  bool _isLoadingMessages = false;
  bool _isSending = false;

  List<Map<String, dynamic>> _chatRooms = [];
  List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _chatChannel;

  @override
  void initState() {
    super.initState();
    _loadChatRooms();
  }

  @override
  void dispose() {
    _chatChannel?.unsubscribe();
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadChatRooms() async {
    setState(() => _isLoadingRooms = true);
    try {
      final rooms = await SupabaseService.getAllChatRooms();
      if (mounted) {
        setState(() {
          _chatRooms = rooms.map(_normalizeRoom).toList();
          _isLoadingRooms = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingRooms = false);
    }
  }

  Map<String, dynamic> _normalizeRoom(Map<String, dynamic> raw) {
    DateTime timestamp;
    final updatedAt = raw['updated_at'] as String?;
    final createdAt = raw['created_at'] as String?;
    if (updatedAt != null) {
      timestamp = DateTime.parse(updatedAt);
    } else if (createdAt != null) {
      timestamp = DateTime.parse(createdAt);
    } else {
      timestamp = DateTime.now();
    }

    return {
      'id': raw['id'],
      'name': raw['name'] as String? ?? 'Sala de Chat',
      'type': raw['type'] as String? ?? 'neighborhood',
      'lastMessage': raw['last_message'] as String? ?? 'Sin mensajes aún',
      'timestamp': timestamp,
      'unreadCount': (raw['unread_count'] as int?) ?? 0,
      'avatar': raw['avatar_url'] as String? ?? '',
      'semanticLabel': 'Sala de chat: ${raw['name'] ?? ''}',
      'isEncrypted': true,
      'participants': (raw['member_count'] as int?) ?? 0,
      'lastSender': raw['last_sender'] as String?,
    };
  }

  Map<String, dynamic> _normalizeMessage(Map<String, dynamic> raw) {
    final sender = raw['sender'] as Map<String, dynamic>?;
    final createdAt = raw['created_at'] as String?;
    final currentUserId = SupabaseService.currentUserId;
    return {
      'id': raw['id'],
      'senderId': raw['sender_id'],
      'senderName': sender?['full_name'] as String? ?? 'Usuario',
      'senderAvatar': sender?['avatar_url'] as String? ?? '',
      'semanticLabel': 'Foto de perfil',
      'message': raw['message'] as String? ?? '',
      'timestamp': createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      'type': 'text',
      'isAuthority': (sender?['role'] as String?) == 'authority',
      'isRead': true,
      'isCurrentUser': raw['sender_id'] == currentUserId,
    };
  }

  Future<void> _selectChat(String chatId, String chatName) async {
    await _chatChannel?.unsubscribe();
    setState(() {
      _selectedChatId = chatId;
      _selectedChatName = chatName;
      _messages = [];
      _isLoadingMessages = true;
    });
    HapticFeedback.lightImpact();
    await _loadMessages(chatId);
    _subscribeToMessages(chatId);
  }

  Future<void> _goBackToList() async {
    await _chatChannel?.unsubscribe();
    _chatChannel = null;
    setState(() {
      _selectedChatId = null;
      _selectedChatName = null;
      _messages = [];
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _loadMessages(String roomId) async {
    try {
      final msgs = await SupabaseService.getChatMessages(roomId);
      if (mounted) {
        setState(() {
          _messages = msgs.map(_normalizeMessage).toList();
          _isLoadingMessages = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMessages = false);
    }
  }

  void _subscribeToMessages(String roomId) {
    _chatChannel = SupabaseService.subscribeToChatMessages(roomId, (raw) {
      // Skip messages from the current user — already inserted optimistically
      if (raw['sender_id'] == SupabaseService.currentUserId) return;
      final msg = _normalizeMessage(raw);
      if (mounted) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedChatId == null || _isSending) return;

    final tempId = 'tmp_${DateTime.now().millisecondsSinceEpoch}';
    final optimistic = {
      'id': tempId,
      'senderId': SupabaseService.currentUserId,
      'senderName': 'Tú',
      'senderAvatar': '',
      'semanticLabel': 'Tu foto de perfil',
      'message': text,
      'timestamp': DateTime.now(),
      'type': 'text',
      'isAuthority': false,
      'isRead': false,
      'isCurrentUser': true,
    };

    setState(() {
      _isTyping = false;
      _isSending = true;
      _messages.add(optimistic);
    });
    _messageController.clear();
    HapticFeedback.mediumImpact();
    _scrollToBottom();

    try {
      await SupabaseService.sendMessage(
        roomId: _selectedChatId!,
        message: text,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _messages.removeWhere((m) => m['id'] == tempId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No se pudo enviar el mensaje. Intenta de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  List<Map<String, dynamic>> get _filteredChatRooms {
    if (_searchController.text.isEmpty) return _chatRooms;
    final q = _searchController.text.toLowerCase();
    return _chatRooms.where((chat) {
      return (chat['name'] as String).toLowerCase().contains(q) ||
          (chat['lastMessage'] as String).toLowerCase().contains(q);
    }).toList();
  }

  void _showChatOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bottomSheetTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'group_add',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Crear grupo nuevo', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Buscar por ubicación', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'topic',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: Text('Buscar por tema', style: theme.textTheme.bodyLarge),
              onTap: () {
                Navigator.pop(context);
                HapticFeedback.lightImpact();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 4.w,
            right: 4.w,
            bottom: 2.h,
          ),
          decoration: BoxDecoration(
            color: theme.appBarTheme.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  if (_selectedChatId != null)
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: _goBackToList,
                    )
                  else
                    const SizedBox.shrink(),
                  Expanded(
                    child: Text(
                      _selectedChatId != null
                          ? (_selectedChatName ?? 'Chat')
                          : 'Chat de Seguridad',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_selectedChatId != null) ...[
                    CustomIconWidget(
                      iconName: 'verified_user',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                  ],
                  IconButton(
                    icon: CustomIconWidget(
                      iconName: _isSearching ? 'close' : 'search',
                      color: theme.colorScheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) _searchController.clear();
                      });
                      HapticFeedback.lightImpact();
                    },
                  ),
                  if (_selectedChatId == null)
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'add_circle_outline',
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      onPressed: () => _showChatOptions(context),
                    ),
                ],
              ),
              if (_isSearching && _selectedChatId == null) ...[
                SizedBox(height: 1.h),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar conversaciones...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: _selectedChatId == null
              ? _buildChatList(theme)
              : _buildChatMessages(theme),
        ),
      ],
    );
  }

  Widget _buildChatList(ThemeData theme) {
    if (_isLoadingRooms) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (_filteredChatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'chat_bubble_outline',
              color: theme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              _searchController.text.isEmpty
                  ? 'No hay conversaciones disponibles'
                  : 'No se encontraron conversaciones',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      itemCount: _filteredChatRooms.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        thickness: 1,
        indent: 20.w,
        color: theme.dividerColor,
      ),
      itemBuilder: (context, index) {
        final chat = _filteredChatRooms[index];
        return ChatListItemWidget(
          chat: chat,
          onTap: () => _selectChat(
            chat['id'] as String,
            chat['name'] as String,
          ),
        );
      },
    );
  }

  Widget _buildChatMessages(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'lock',
                color: theme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Cifrado de extremo a extremo activo',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _isLoadingMessages
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : _messages.isEmpty
                  ? Center(
                      child: Text(
                        'Sé el primero en enviar un mensaje',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ChatMessageWidget(
                          message: message,
                          isCurrentUser:
                              (message['isCurrentUser'] as bool?) ?? false,
                        );
                      },
                    ),
        ),

        if (_isTyping)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Row(
              children: [
                Text(
                  'Escribiendo...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

        ChatInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          onTypingChanged: (isTyping) => setState(() => _isTyping = isTyping),
        ),
      ],
    );
  }
}
