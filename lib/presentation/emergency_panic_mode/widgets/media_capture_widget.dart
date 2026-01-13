import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for audio recording and photo/video capture controls
class MediaCaptureWidget extends StatelessWidget {
  final bool isRecording;
  final String recordingDuration;
  final VoidCallback onToggleRecording;
  final VoidCallback onCapturePhoto;
  final VoidCallback onCaptureVideo;

  const MediaCaptureWidget({
    super.key,
    required this.isRecording,
    required this.recordingDuration,
    required this.onToggleRecording,
    required this.onCapturePhoto,
    required this.onCaptureVideo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'camera_alt',
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Captura de Evidencia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Audio, fotos y videos',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isRecording
                  ? theme.colorScheme.error.withValues(alpha: 0.1)
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: isRecording
                  ? Border.all(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          onToggleRecording();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRecording
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          foregroundColor: isRecording
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: CustomIconWidget(
                          iconName: isRecording ? 'stop' : 'mic',
                          color: isRecording
                              ? theme.colorScheme.onError
                              : theme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        label: Text(
                          isRecording ? 'Detener Audio' : 'Grabar Audio',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isRecording
                                ? theme.colorScheme.onError
                                : theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isRecording) ...[
                  SizedBox(height: 1.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Grabando: $recordingDuration',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onCapturePhoto();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: CustomIconWidget(
                    iconName: 'photo_camera',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Foto',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onCaptureVideo();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: CustomIconWidget(
                    iconName: 'videocam',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Video',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
