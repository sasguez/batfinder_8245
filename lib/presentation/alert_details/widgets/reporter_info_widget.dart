import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReporterInfoWidget extends StatelessWidget {
  final Map<String, dynamic> reporterData;

  const ReporterInfoWidget({super.key, required this.reporterData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isAnonymous = reporterData['isAnonymous'] as bool? ?? false;
    final bool isVerified = reporterData['isVerified'] as bool? ?? false;
    final int reputationScore =
        reporterData['reputationScore'] as int? ?? 0;

    if (isAnonymous) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'person_outline',
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportero Anónimo',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Identidad protegida por seguridad',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline, width: 1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CustomImageWidget(
                imageUrl: reporterData['avatar'] as String? ?? '',
                width: 12.w,
                height: 12.w,
                fit: BoxFit.cover,
                semanticLabel:
                    reporterData['avatarSemanticLabel'] as String? ??
                    'Foto de perfil del reportero',
              ),
              if (isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: const CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        reporterData['name'] as String? ?? 'Desconocido',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      SizedBox(width: 1.w),
                      const CustomIconWidget(
                        iconName: 'verified',
                        color: Color(0xFF2E7D32),
                        size: 16,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    const CustomIconWidget(
                      iconName: 'star',
                      color: Color(0xFFFFD700),
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Reputación: $reputationScore',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
