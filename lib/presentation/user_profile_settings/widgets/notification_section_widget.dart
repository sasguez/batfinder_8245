import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Notification Section Widget
/// Notification preferences with toggle switches
class NotificationSectionWidget extends StatefulWidget {
  const NotificationSectionWidget({super.key});

  @override
  State<NotificationSectionWidget> createState() =>
      _NotificationSectionWidgetState();
}

class _NotificationSectionWidgetState extends State<NotificationSectionWidget> {
  bool _proximityWarnings = true;
  bool _communityUpdates = true;
  bool _emergencyBroadcasts = true;
  bool _authorityAnnouncements = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

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
              'Notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Alert Types
          _buildSwitchTile(
            context: context,
            icon: 'warning',
            label: 'Alertas de Proximidad',
            subtitle: 'Incidentes cerca de tu ubicación',
            value: _proximityWarnings,
            onChanged: (value) {
              setState(() => _proximityWarnings = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildSwitchTile(
            context: context,
            icon: 'groups',
            label: 'Actualizaciones de Comunidad',
            subtitle: 'Noticias y consejos de seguridad',
            value: _communityUpdates,
            onChanged: (value) {
              setState(() => _communityUpdates = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildSwitchTile(
            context: context,
            icon: 'emergency',
            label: 'Transmisiones de Emergencia',
            subtitle: 'Alertas críticas de seguridad',
            value: _emergencyBroadcasts,
            onChanged: (value) {
              setState(() => _emergencyBroadcasts = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildSwitchTile(
            context: context,
            icon: 'campaign',
            label: 'Anuncios de Autoridades',
            subtitle: 'Comunicados oficiales',
            value: _authorityAnnouncements,
            onChanged: (value) {
              setState(() => _authorityAnnouncements = value);
            },
          ),

          Divider(height: 1, thickness: 1),

          // Customization Header
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Text(
              'Personalización',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _buildSwitchTile(
            context: context,
            icon: 'volume_up',
            label: 'Sonido',
            subtitle: 'Reproducir sonido de notificación',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() => _soundEnabled = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildSwitchTile(
            context: context,
            icon: 'vibration',
            label: 'Vibración',
            subtitle: 'Vibrar al recibir notificaciones',
            value: _vibrationEnabled,
            onChanged: (value) {
              setState(() => _vibrationEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
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
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
