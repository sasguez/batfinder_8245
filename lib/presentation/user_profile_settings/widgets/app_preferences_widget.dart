import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// App Preferences Widget
/// App-specific settings and preferences
class AppPreferencesWidget extends StatefulWidget {
  const AppPreferencesWidget({super.key});

  @override
  State<AppPreferencesWidget> createState() => _AppPreferencesWidgetState();
}

class _AppPreferencesWidgetState extends State<AppPreferencesWidget> {
  String _offlineStorageLimit = '500 MB';
  bool _batteryOptimization = true;
  bool _backgroundLocation = true;

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
              'Preferencias de Aplicación',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Offline Storage Limit
          InkWell(
            onTap: () => _showStorageLimitDialog(context),
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
                        iconName: 'storage',
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
                          'Límite de Almacenamiento Offline',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _offlineStorageLimit,
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

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Battery Optimization
          _buildSwitchTile(
            context: context,
            icon: 'battery_charging_full',
            label: 'Optimización de Batería',
            subtitle: 'Reduce el consumo de energía',
            value: _batteryOptimization,
            onChanged: (value) {
              setState(() => _batteryOptimization = value);
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Background Location
          _buildSwitchTile(
            context: context,
            icon: 'my_location',
            label: 'Ubicación en Segundo Plano',
            subtitle: 'Permite rastreo continuo de ubicación',
            value: _backgroundLocation,
            onChanged: (value) {
              setState(() => _backgroundLocation = value);
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

  void _showStorageLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Límite de Almacenamiento Offline'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStorageOption(context, '100 MB'),
            _buildStorageOption(context, '250 MB'),
            _buildStorageOption(context, '500 MB'),
            _buildStorageOption(context, '1 GB'),
            _buildStorageOption(context, 'Sin límite'),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageOption(BuildContext context, String value) {
    final theme = Theme.of(context);
    final isSelected = _offlineStorageLimit == value;

    return InkWell(
      onTap: () {
        setState(() => _offlineStorageLimit = value);
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _offlineStorageLimit,
              onChanged: (val) {
                setState(() => _offlineStorageLimit = val!);
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
