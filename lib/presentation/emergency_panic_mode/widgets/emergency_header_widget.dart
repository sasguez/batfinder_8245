import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Emergency header widget showing countdown and status
class EmergencyHeaderWidget extends StatelessWidget {
  final int remainingSeconds;
  final bool isRecording;
  final VoidCallback onCancelEmergency;

  const EmergencyHeaderWidget({
    super.key,
    required this.remainingSeconds,
    required this.isRecording,
    required this.onCancelEmergency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MODO DE EMERGENCIA',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onError,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Servicios de emergencia serán notificados',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onError.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onError.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'warning_amber_rounded',
                  color: theme.colorScheme.onError,
                  size: 32,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: theme.colorScheme.onError.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'timer',
                  color: theme.colorScheme.onError,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Notificación automática en: ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onError,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
                    color: theme.colorScheme.onError,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Grabación de audio activa',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
