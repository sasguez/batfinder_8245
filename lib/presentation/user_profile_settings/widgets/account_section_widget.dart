import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountSectionWidget extends StatelessWidget {
  final Map<String, dynamic> userData;
  final bool isGoogleUser;

  const AccountSectionWidget({
    super.key,
    required this.userData,
    required this.isGoogleUser,
  });

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

          _buildInfoTile(
            context: context,
            icon: 'person',
            label: 'Nombre',
            value: userData['name'] as String,
            onTap: () {},
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildInfoTile(
            context: context,
            icon: 'email',
            label: 'Correo Electrónico',
            value: userData['email'] as String,
            onTap: isGoogleUser ? null : () {},
            disabled: isGoogleUser,
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildInfoTile(
            context: context,
            icon: 'phone',
            label: 'Teléfono',
            value: userData['phone'] as String,
            onTap: () {},
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildInfoTile(
            context: context,
            icon: 'lock',
            label: 'Contraseña',
            value: '••••••••',
            onTap: isGoogleUser ? null : () {},
            disabled: isGoogleUser,
            disabledHint: isGoogleUser
                ? 'Gestionada por Google'
                : null,
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
    required VoidCallback? onTap,
    bool disabled = false,
    String? disabledHint,
  }) {
    final theme = Theme.of(context);

    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: disabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
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
                      color: disabled
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  if (disabledHint != null) ...[
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lock',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 11,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          disabledHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!disabled)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              )
            else
              CustomIconWidget(
                iconName: 'block',
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 18,
              ),
          ],
        ),
      ),
    );

    if (disabled) {
      return Opacity(opacity: 0.55, child: tile);
    }
    return tile;
  }
}
