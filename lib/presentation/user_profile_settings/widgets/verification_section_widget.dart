import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Verification Section Widget
/// Account verification status and re-verification options
class VerificationSectionWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const VerificationSectionWidget({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Verificación de Cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Phone Verification
          _buildVerificationTile(
            context: context,
            icon: 'phone',
            label: 'Teléfono',
            isVerified: userData["verifiedPhone"] as bool,
            onTap: () {
              // Re-verify phone
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Email Verification
          _buildVerificationTile(
            context: context,
            icon: 'email',
            label: 'Correo Electrónico',
            isVerified: userData["verifiedEmail"] as bool,
            onTap: () {
              // Re-verify email
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Document Verification
          _buildVerificationTile(
            context: context,
            icon: 'badge',
            label: 'Documentos de Identidad',
            isVerified: userData["verifiedDocuments"] as bool,
            onTap: () {
              // Verify documents
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTile({
    required BuildContext context,
    required String icon,
    required String label,
    required bool isVerified,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isVerified
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: isVerified ? Colors.green : theme.colorScheme.error,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: isVerified ? 'check_circle' : 'cancel',
                        color: isVerified
                            ? Colors.green
                            : theme.colorScheme.error,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isVerified ? 'Verificado' : 'No verificado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isVerified
                              ? Colors.green
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            isVerified
                ? CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Verificar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
