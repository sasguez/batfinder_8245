import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Chat input widget for message composition
class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(bool) onTypingChanged;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onTypingChanged,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget> {
  bool _isTyping = false;

  void _handleTextChanged(String text) {
    final isTyping = text.trim().isNotEmpty;
    if (isTyping != _isTyping) {
      setState(() => _isTyping = isTyping);
      widget.onTypingChanged(isTyping);
    }
  }

  void _showAttachmentOptions(BuildContext context) {
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
            SizedBox(height: 2.h),
            Text('Adjuntar', style: theme.textTheme.titleMedium),
            SizedBox(height: 2.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  context,
                  icon: 'photo_camera',
                  label: 'Cámara',
                  color: theme.colorScheme.primary,
                ),
                _buildAttachmentOption(
                  context,
                  icon: 'photo_library',
                  label: 'Galería',
                  color: Color(0xFF2E7D32),
                ),
                _buildAttachmentOption(
                  context,
                  icon: 'location_on',
                  label: 'Ubicación',
                  color: Color(0xFFF57C00),
                ),
                _buildAttachmentOption(
                  context,
                  icon: 'mic',
                  label: 'Audio',
                  color: theme.colorScheme.error,
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required String icon,
    required String label,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 18.w,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Column(
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(iconName: icon, color: color, size: 28),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            IconButton(
              icon: CustomIconWidget(
                iconName: 'add_circle',
                color: theme.colorScheme.primary,
                size: 28,
              ),
              onPressed: () => _showAttachmentOptions(context),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 2.w),

            // Text input
            Expanded(
              child: Container(
                constraints: BoxConstraints(maxHeight: 15.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor, width: 1),
                ),
                child: TextField(
                  controller: widget.controller,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                  ),
                  style: theme.textTheme.bodyMedium,
                  onChanged: _handleTextChanged,
                ),
              ),
            ),
            SizedBox(width: 2.w),

            // Send button
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: _isTyping
                    ? theme.colorScheme.primary
                    : theme.colorScheme.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: CustomIconWidget(
                  iconName: 'send',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                onPressed: _isTyping ? widget.onSend : null,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
