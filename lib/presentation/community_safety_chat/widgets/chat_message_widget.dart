import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Chat message widget for displaying individual messages
class ChatMessageWidget extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isCurrentUser;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageType = message["type"] as String;
    final isAuthority = message["isAuthority"] as bool;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isCurrentUser) ...[
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isAuthority
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
              ),
              child: ClipOval(
                child: CustomImageWidget(
                  imageUrl: message["senderAvatar"],
                  width: 10.w,
                  height: 10.w,
                  fit: BoxFit.cover,
                  semanticLabel: message["semanticLabel"],
                ),
              ),
            ),
            SizedBox(width: 2.w),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message["senderName"],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isAuthority) ...[
                        SizedBox(width: 1.w),
                        CustomIconWidget(
                          iconName: 'verified',
                          color: theme.colorScheme.primary,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                SizedBox(height: 0.5.h),

                _buildMessageContent(theme, messageType),

                SizedBox(height: 0.5.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTimestamp(message["timestamp"]),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 9.sp,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: message["isRead"] ? 'done_all' : 'done',
                        color: message["isRead"]
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        size: 14,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          if (isCurrentUser) ...[
            SizedBox(width: 2.w),
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  'Tú',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme, String messageType) {
    switch (messageType) {
      case 'text':
        return _buildTextMessage(theme);
      case 'image':
        return _buildImageMessage(theme);
      case 'location':
        return _buildLocationMessage(theme);
      default:
        return _buildTextMessage(theme);
    }
  }

  Widget _buildTextMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primary
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxWidth: 70.w),
      child: Text(
        message["message"],
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isCurrentUser
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildImageMessage(ThemeData theme) {
    return Container(
      constraints: BoxConstraints(maxWidth: 70.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomImageWidget(
          imageUrl: message["imageUrl"],
          width: 70.w,
          height: 40.h,
          fit: BoxFit.cover,
          semanticLabel: message["imageSemanticLabel"],
        ),
      ),
    );
  }

  Widget _buildLocationMessage(ThemeData theme) {
    final locationData = message["locationData"] as Map<String, dynamic>;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxWidth: 70.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Ubicación compartida',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            locationData["address"],
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            height: 20.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'map',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 48,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Toca para ver en el mapa',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
