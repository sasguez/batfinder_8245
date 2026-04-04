import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Privacy Section Widget
/// Data sharing preferences and privacy controls
class PrivacySectionWidget extends StatefulWidget {
  const PrivacySectionWidget({super.key});

  @override
  State<PrivacySectionWidget> createState() => _PrivacySectionWidgetState();
}

class _PrivacySectionWidgetState extends State<PrivacySectionWidget> {
  bool _shareDataWithAuthorities = true;
  bool _allowAnonymousReporting = true;
  String _locationAccuracy = 'Alta';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacidad y Datos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Cumple con la Ley de Protección de Datos de Colombia',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Share Data with Authorities
          _buildSwitchTile(
            context: context,
            icon: 'shield',
            label: 'Compartir Datos con Autoridades',
            subtitle: 'Permite que las autoridades accedan a tus reportes',
            value: _shareDataWithAuthorities,
            onChanged: (value) {
              setState(() => _shareDataWithAuthorities = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Anonymous Reporting
          _buildSwitchTile(
            context: context,
            icon: 'visibility_off',
            label: 'Reportes Anónimos',
            subtitle: 'Oculta tu identidad en los reportes públicos',
            value: _allowAnonymousReporting,
            onChanged: (value) {
              setState(() => _allowAnonymousReporting = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Location Accuracy
          InkWell(
            onTap: () => _showLocationAccuracyDialog(context),
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
                        iconName: 'location_on',
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
                          'Precisión de Ubicación',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _locationAccuracy,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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

  void _showLocationAccuracyDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Precisión de Ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAccuracyOption(context, 'Alta', 'Ubicación exacta (GPS)'),
            _buildAccuracyOption(context, 'Media', 'Aproximada (100m)'),
            _buildAccuracyOption(context, 'Baja', 'General (1km)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyOption(
    BuildContext context,
    String value,
    String description,
  ) {
    final theme = Theme.of(context);
    final isSelected = _locationAccuracy == value;

    return InkWell(
      onTap: () {
        setState(() => _locationAccuracy = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _locationAccuracy,
              onChanged: (val) {
                setState(() => _locationAccuracy = val!);
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
