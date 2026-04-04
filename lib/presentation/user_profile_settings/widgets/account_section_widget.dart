import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Account Section Widget
/// Personal information management
class AccountSectionWidget extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AccountSectionWidget({super.key, required this.userData});

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
              'Información de Cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Name Field
          _buildInfoTile(
            context: context,
            icon: 'person',
            label: 'Nombre',
            value: userData["name"] as String,
            onTap: () {
              // Edit name
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Email Field
          _buildInfoTile(
            context: context,
            icon: 'email',
            label: 'Correo Electrónico',
            value: userData["email"] as String,
            onTap: () {
              // Edit email
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Phone Field
          _buildInfoTile(
            context: context,
            icon: 'phone',
            label: 'Teléfono',
            value: userData["phone"] as String,
            onTap: () {
              // Edit phone
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Password Field
          _buildInfoTile(
            context: context,
            icon: 'lock',
            label: 'Contraseña',
            value: '••••••••',
            onTap: () {
              // Change password
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Biometric Re-enrollment
          _buildInfoTile(
            context: context,
            icon: 'fingerprint',
            label: 'Autenticación Biométrica',
            value: 'Configurar',
            onTap: () {
              // Biometric setup
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
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
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: theme.colorScheme.primary,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
