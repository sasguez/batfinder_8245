import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/chat_input_widget.dart';
import './widgets/chat_list_item_widget.dart';
import './widgets/chat_message_widget.dart';

/// Community Safety Chat Screen
/// Facilitates secure communication between citizens, authorities, and NGOs
/// Tab navigation with Chat tab active
class CommunitySafetyChat extends StatefulWidget {
  const CommunitySafetyChat({super.key});

  @override
  State<CommunitySafetyChat> createState() => _CommunitySafetyChatState();
}

class _CommunitySafetyChatState extends State<CommunitySafetyChat>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSearching = false;
  String? _selectedChatId;
  bool _isTyping = false;

  // Mock chat rooms data
  final List<Map<String, dynamic>> _chatRooms = [
    {
      "id": "chat_001",
      "name": "Chapinero Norte - Seguridad",
      "type": "neighborhood",
      "lastMessage": "Patrulla policial reportada en Calle 72",
      "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
      "unreadCount": 3,
      "avatar":
          "https://images.unsplash.com/photo-1695454507598-39fb421afb74",
      "semanticLabel":
          "Aerial view of Chapinero neighborhood with residential buildings and green spaces",
      "isEncrypted": true,
      "participants": 156,
      "lastSender": "Oficial Rodríguez",
    },
    {
      "id": "chat_002",
      "name": "Alerta: Robo en Usaquén",
      "type": "incident",
      "lastMessage": "Sospechoso detenido, situación controlada",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "unreadCount": 0,
      "avatar":
          "https://images.unsplash.com/photo-1606007349182-207c2964d299",
      "semanticLabel":
          "Police officer in uniform standing near patrol car at night",
      "isEncrypted": true,
      "participants": 45,
      "lastSender": "Comandante Silva",
    },
    {
      "id": "chat_003",
      "name": "Avisos Policía Nacional",
      "type": "authority",
      "lastMessage": "Operativo de seguridad este fin de semana",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "unreadCount": 1,
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1f0ab5492-1768342129691.png",
      "semanticLabel":
          "Colombian police badge and official emblem on dark blue uniform",
      "isEncrypted": true,
      "participants": 2340,
      "lastSender": "Policía Nacional",
    },
    {
      "id": "chat_004",
      "name": "Coordinación Emergencias",
      "type": "emergency",
      "lastMessage": "Ambulancia en camino a Cra 7 con 85",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "unreadCount": 0,
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_14c023e35-1764749886822.png",
      "semanticLabel":
          "Emergency response team with red cross ambulance and medical equipment",
      "isEncrypted": true,
      "participants": 23,
      "lastSender": "Cruz Roja",
    },
    {
      "id": "chat_005",
      "name": "Suba - Vigilancia Vecinal",
      "type": "neighborhood",
      "lastMessage": "Reunión de seguridad mañana 6pm",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "unreadCount": 5,
      "avatar":
          "https://images.unsplash.com/photo-1511584221885-5f4e4bcf4570",
      "semanticLabel":
          "Residential neighborhood street with houses and community watch sign",
      "isEncrypted": true,
      "participants": 89,
      "lastSender": "María González",
    },
    {
      "id": "chat_006",
      "name": "ONG Seguridad Ciudadana",
      "type": "ngo",
      "lastMessage": "Taller de prevención este sábado",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "unreadCount": 0,
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_15e1bd1a8-1767910541627.png",
      "semanticLabel":
          "Community volunteers in safety vests organizing neighborhood watch program",
      "isEncrypted": true,
      "participants": 234,
      "lastSender": "Fundación Paz",
    },
  ];

  // Mock messages for selected chat
  List<Map<String, dynamic>> _getMessagesForChat(String chatId) {
    return [
      {
        "id": "msg_001",
        "senderId": "user_123",
        "senderName": "Oficial Rodríguez",
        "senderAvatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1a906f7b2-1763294156295.png",
        "semanticLabel":
            "Profile photo of police officer in uniform with short dark hair",
        "message":
            "Patrulla policial reportada en Calle 72 con Carrera 7. Todo tranquilo en la zona.",
        "timestamp": DateTime.now().subtract(Duration(minutes: 5)),
        "type": "text",
        "isAuthority": true,
        "isRead": true,
      },
      {
        "id": "msg_002",
        "senderId": "user_456",
        "senderName": "Ana Martínez",
        "senderAvatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1bc8b4514-1763299107061.png",
        "semanticLabel":
            "Profile photo of woman with long brown hair wearing casual clothing",
        "message":
            "Gracias por la información. ¿Hasta qué hora estará la patrulla?",
        "timestamp": DateTime.now().subtract(Duration(minutes: 4)),
        "type": "text",
        "isAuthority": false,
        "isRead": true,
      },
      {
        "id": "msg_003",
        "senderId": "user_123",
        "senderName": "Oficial Rodríguez",
        "senderAvatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1a906f7b2-1763294156295.png",
        "semanticLabel":
            "Profile photo of police officer in uniform with short dark hair",
        "message":
            "Estaremos hasta las 10pm. Pueden contactarnos al 123 para emergencias.",
        "timestamp": DateTime.now().subtract(Duration(minutes: 3)),
        "type": "text",
        "isAuthority": true,
        "isRead": true,
      },
      {
        "id": "msg_004",
        "senderId": "user_789",
        "senderName": "Carlos Pérez",
        "senderAvatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_17f889464-1763294308784.png",
        "semanticLabel":
            "Profile photo of middle-aged man with glasses and gray hair",
        "message": null,
        "timestamp": DateTime.now().subtract(Duration(minutes: 2)),
        "type": "location",
        "isAuthority": false,
        "isRead": true,
        "locationData": {
          "latitude": 4.6533,
          "longitude": -74.0836,
          "address": "Calle 72 #7-45, Chapinero",
        },
      },
      {
        "id": "msg_005",
        "senderId": "user_456",
        "senderName": "Ana Martínez",
        "senderAvatar":
            "https://img.rocket.new/generatedImages/rocket_gen_img_1bc8b4514-1763299107061.png",
        "semanticLabel":
            "Profile photo of woman with long brown hair wearing casual clothing",
        "message": null,
        "timestamp": DateTime.now().subtract(Duration(minutes: 1)),
        "type": "image",
        "isAuthority": false,
        "isRead": false,
        "imageUrl":
            "https://images.unsplash.com/photo-1716156484930-867e2753c01d",
        "imageSemanticLabel":
            "Street view of Chapinero neighborhood showing police patrol car parked on residential street",
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredChatRooms {
    if (_searchController.text.isEmpty) {
      return _chatRooms;
    }
    return _chatRooms.where((chat) {
      return (chat["name"] as String).toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          (chat["lastMessage"] as String).toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
    }).toList();
  }

  void _selectChat(String chatId) {
    setState(() {
      _selectedChatId = chatId;
      // Mark messages as read
      final chatIndex = _chatRooms.indexWhere((chat) => chat["id"] == chatId);
      if (chatIndex != -1) {
        _chatRooms[chatIndex]["unreadCount"] = 0;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isTyping = false;
      _messageController.clear();
    });

    HapticFeedback.mediumImpact();

    // Scroll to bottom after sending
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showChatOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.bottomSheetTheme.backgroundColor,
      shape: RoundedRectangleBorder(
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
              title: Text(
                'Crear grupo nuevo',
                style: theme.textTheme.bodyLarge,
              ),
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
              title: Text(
                'Buscar por ubicación',
                style: theme.textTheme.bodyLarge,
              ),
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
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom App Bar
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
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _selectedChatId != null
                      ? IconButton(
                          icon: CustomIconWidget(
                            iconName: 'arrow_back',
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() => _selectedChatId = null);
                            HapticFeedback.lightImpact();
                          },
                        )
                      : SizedBox.shrink(),
                  Expanded(
                    child: Text(
                      _selectedChatId != null
                          ? _chatRooms.firstWhere(
                              (chat) => chat["id"] == _selectedChatId,
                            )["name"]
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
                        if (!_isSearching) {
                          _searchController.clear();
                        }
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
                    prefixIcon: Icon(Icons.search, size: 20),
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
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ],
          ),
        ),

        // Content Area
        Expanded(
          child: _selectedChatId == null
              ? _buildChatList(theme)
              : _buildChatMessages(theme),
        ),
      ],
    );
  }

  Widget _buildChatList(ThemeData theme) {
    return _filteredChatRooms.isEmpty
        ? Center(
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
                  'No se encontraron conversaciones',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        : ListView.separated(
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
                onTap: () => _selectChat(chat["id"]),
              );
            },
          );
  }

  Widget _buildChatMessages(ThemeData theme) {
    final messages = _getMessagesForChat(_selectedChatId!);

    return Column(
      children: [
        // Encryption indicator
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

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ChatMessageWidget(
                message: message,
                isCurrentUser: message["senderId"] != "user_123",
              );
            },
          ),
        ),

        // Typing indicator
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

        // Message input
        ChatInputWidget(
          controller: _messageController,
          onSend: _sendMessage,
          onTypingChanged: (isTyping) {
            setState(() => _isTyping = isTyping);
          },
        ),
      ],
    );
  }
}
