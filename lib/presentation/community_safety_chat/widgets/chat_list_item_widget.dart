import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Chat list item widget for displaying individual chat rooms
class ChatListItemWidget extends StatelessWidget {
  final Map<String, dynamic> chat;
  final VoidCallback onTap;

  const ChatListItemWidget({super.key, required this.chat, required this.onTap});

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(timestamp);
    }
  }

  Color _getChatTypeColor(String type, ThemeData theme) {
    switch (type) {
      case 'emergency':
        return theme.colorScheme.error;
      case 'authority':
        return theme.colorScheme.primary;
      case 'incident':
        return Color(0xFFF57C00); // Warning color
      case 'ngo':
        return Color(0xFF2E7D32); // Success color
      default:
        return theme.colorScheme.secondary;
    }
  }

  IconData _getChatTypeIcon(String type) {
    switch (type) {
      case 'emergency':
        return Icons.emergency;
      case 'authority':
        return Icons.shield;
      case 'incident':
        return Icons.warning_amber_rounded;
      case 'ngo':
        return Icons.volunteer_activism;
      default:
        return Icons.group;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = chat["unreadCount"] as int;
    final hasUnread = unreadCount > 0;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with type indicator
            Stack(
              children: [
                Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getChatTypeColor(chat["type"], theme),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: CustomImageWidget(
                      imageUrl: chat["avatar"],
                      width: 14.w,
                      height: 14.w,
                      fit: BoxFit.cover,
                      semanticLabel: chat["semanticLabel"],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: _getChatTypeColor(chat["type"], theme),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getChatTypeIcon(chat["type"]),
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 3.w),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat["name"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      if (chat["isEncrypted"] == true)
                        CustomIconWidget(
                          iconName: 'lock',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),

                  // Last message
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: [
                              if (chat["lastSender"] != null)
                                TextSpan(
                                  text: '${chat["lastSender"]}: ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              TextSpan(
                                text: chat["lastMessage"],
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: hasUnread
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                                  fontWeight: hasUnread
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),

                  // Participants count
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'people',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${chat["participants"]} participantes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Timestamp and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTimestamp(chat["timestamp"]),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasUnread
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (hasUnread) ...[
                  SizedBox(height: 1.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(minWidth: 5.w),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
