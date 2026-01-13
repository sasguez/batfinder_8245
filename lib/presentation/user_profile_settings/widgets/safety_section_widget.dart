import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Safety Section Widget
/// Emergency contacts and safety settings configuration
class SafetySectionWidget extends StatefulWidget {
  const SafetySectionWidget({super.key});

  @override
  State<SafetySectionWidget> createState() => _SafetySectionWidgetState();
}

class _SafetySectionWidgetState extends State<SafetySectionWidget> {
  String _panicButtonSensitivity = 'Media';
  String _locationSharingDuration = '30 minutos';
  String _geofenceRadius = '500m';

  final List<Map<String, dynamic>> emergencyContacts = [
    {
      "name": "Carlos González",
      "phone": "+57 300 987 6543",
      "relation": "Esposo",
    },
    {
      "name": "Ana María López",
      "phone": "+57 301 234 5678",
      "relation": "Hermana",
    },
  ];

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
              'Configuración de Seguridad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Emergency Contacts
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Contactos de Emergencia',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${emergencyContacts.length}/5',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                ...emergencyContacts.map(
                  (contact) => _buildContactCard(context, contact),
                ),
                SizedBox(height: 1.h),
                OutlinedButton.icon(
                  onPressed: () {
                    // Add emergency contact
                  },
                  icon: CustomIconWidget(
                    iconName: 'add',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text('Agregar Contacto'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Panic Button Sensitivity
          InkWell(
            onTap: () => _showSensitivityDialog(context),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'touch_app',
                        color: theme.colorScheme.error,
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
                          'Sensibilidad del Botón de Pánico',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _panicButtonSensitivity,
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

          // Location Sharing Duration
          InkWell(
            onTap: () => _showDurationDialog(context),
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
                        iconName: 'schedule',
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
                          'Duración de Compartir Ubicación',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _locationSharingDuration,
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

          // Geofence Radius
          InkWell(
            onTap: () => _showRadiusDialog(context),
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
                        iconName: 'radar',
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
                          'Radio de Geocerca (Casa/Trabajo)',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _geofenceRadius,
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

  Widget _buildContactCard(BuildContext context, Map<String, dynamic> contact) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.secondary,
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
                  contact["name"] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${contact["relation"]} • ${contact["phone"]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Remove contact
            },
            icon: CustomIconWidget(
              iconName: 'delete_outline',
              color: theme.colorScheme.error,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _showSensitivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sensibilidad del Botón de Pánico'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              context,
              'Alta',
              'Activación instantánea',
              _panicButtonSensitivity,
              (value) {
                setState(() => _panicButtonSensitivity = value);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(
              context,
              'Media',
              'Mantener presionado 2 segundos',
              _panicButtonSensitivity,
              (value) {
                setState(() => _panicButtonSensitivity = value);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(
              context,
              'Baja',
              'Mantener presionado 5 segundos',
              _panicButtonSensitivity,
              (value) {
                setState(() => _panicButtonSensitivity = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Duración de Compartir Ubicación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              context,
              '15 minutos',
              '',
              _locationSharingDuration,
              (value) {
                setState(() => _locationSharingDuration = value);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(
              context,
              '30 minutos',
              '',
              _locationSharingDuration,
              (value) {
                setState(() => _locationSharingDuration = value);
                Navigator.pop(context);
              },
            ),
            _buildOptionTile(context, '1 hora', '', _locationSharingDuration, (
              value,
            ) {
              setState(() => _locationSharingDuration = value);
              Navigator.pop(context);
            }),
            _buildOptionTile(
              context,
              'Hasta cancelar',
              '',
              _locationSharingDuration,
              (value) {
                setState(() => _locationSharingDuration = value);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Radio de Geocerca'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(context, '100m', '', _geofenceRadius, (value) {
              setState(() => _geofenceRadius = value);
              Navigator.pop(context);
            }),
            _buildOptionTile(context, '500m', '', _geofenceRadius, (value) {
              setState(() => _geofenceRadius = value);
              Navigator.pop(context);
            }),
            _buildOptionTile(context, '1km', '', _geofenceRadius, (value) {
              setState(() => _geofenceRadius = value);
              Navigator.pop(context);
            }),
            _buildOptionTile(context, '2km', '', _geofenceRadius, (value) {
              setState(() => _geofenceRadius = value);
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    String value,
    String subtitle,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    final theme = Theme.of(context);
    final isSelected = currentValue == value;

    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: currentValue,
              onChanged: (val) => onChanged(val!),
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
                  subtitle.isNotEmpty
                      ? Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
