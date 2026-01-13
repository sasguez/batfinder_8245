import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Accessibility Section Widget
/// Accessibility options for visually impaired users
class AccessibilitySectionWidget extends StatefulWidget {
  const AccessibilitySectionWidget({super.key});

  @override
  State<AccessibilitySectionWidget> createState() =>
      _AccessibilitySectionWidgetState();
}

class _AccessibilitySectionWidgetState
    extends State<AccessibilitySectionWidget> {
  bool _highContrastMode = false;
  bool _largeText = false;
  bool _reducedMotion = false;
  bool _screenReaderOptimized = true;

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
              'Accesibilidad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // High Contrast Mode
          _buildSwitchTile(
            context: context,
            icon: 'contrast',
            label: 'Modo de Alto Contraste',
            subtitle: 'Mejora la visibilidad de elementos',
            value: _highContrastMode,
            onChanged: (value) {
              setState(() => _highContrastMode = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Large Text
          _buildSwitchTile(
            context: context,
            icon: 'text_fields',
            label: 'Texto Grande',
            subtitle: 'Aumenta el tamaño del texto',
            value: _largeText,
            onChanged: (value) {
              setState(() => _largeText = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Reduced Motion
          _buildSwitchTile(
            context: context,
            icon: 'motion_photos_off',
            label: 'Movimiento Reducido',
            subtitle: 'Minimiza animaciones y transiciones',
            value: _reducedMotion,
            onChanged: (value) {
              setState(() => _reducedMotion = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Screen Reader Optimization
          _buildSwitchTile(
            context: context,
            icon: 'record_voice_over',
            label: 'Optimización para Lector de Pantalla',
            subtitle: 'VoiceOver/TalkBack mejorado',
            value: _screenReaderOptimized,
            onChanged: (value) {
              setState(() => _screenReaderOptimized = value);
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
