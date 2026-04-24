import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/supabase_service.dart';

class ProfileHeaderWidget extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfileHeaderWidget({super.key, required this.userData});

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  bool _isUploading = false;
  String? _uploadedAvatarUrl;

  Future<void> _handleAvatarEdit() async {
    final theme = Theme.of(context);

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Tomar Foto'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx, ImageSource.camera);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Elegir de la Galería'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(ctx, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final photo = await picker.pickImage(source: source, imageQuality: 80);
    if (photo == null || !mounted) return;

    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    setState(() => _isUploading = true);
    try {
      final bytes = await photo.readAsBytes();
      final url = await SupabaseService.uploadAvatar(userId, bytes);
      if (mounted && url != null) {
        HapticFeedback.mediumImpact();
        setState(() => _uploadedAvatarUrl = url);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al subir la foto. Intenta de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = _uploadedAvatarUrl ?? widget.userData['avatar'] as String;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _isUploading
                      ? Container(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : CustomImageWidget(
                          imageUrl: avatarUrl,
                          width: 25.w,
                          height: 25.w,
                          fit: BoxFit.cover,
                          semanticLabel: widget.userData['semanticLabel'] as String,
                        ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploading ? null : _handleAvatarEdit,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: _isUploading
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.surface, width: 2),
                    ),
                    child: CustomIconWidget(
                      iconName: _isUploading ? 'hourglass_empty' : 'camera_alt',
                      color: theme.colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          Text(
            widget.userData['name'] as String,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 1.h),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'verified_user',
                  color: theme.colorScheme.secondary,
                  size: 16,
                ),
                SizedBox(width: 1.w),
                Text(
                  widget.userData['role'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(iconName: 'star', color: Colors.amber, size: 24),
                SizedBox(width: 2.w),
                Text(
                  '${widget.userData["reputationScore"]}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'Puntuación de Reputación',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            '${widget.userData["totalReports"]} reportes enviados',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
