import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../routes/app_routes.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class SafetySectionWidget extends StatefulWidget {
  const SafetySectionWidget({super.key});

  @override
  State<SafetySectionWidget> createState() => _SafetySectionWidgetState();
}

class _SafetySectionWidgetState extends State<SafetySectionWidget> {
  int _contactCount = 0;
  bool _loadingCount = true;
  String _locationSharingDuration = '30 minutos';
  String _geofenceRadius = '500m';

  @override
  void initState() {
    super.initState();
    _loadContactCount();
    _loadSafetyPreferences();
  }

  Future<void> _loadContactCount() async {
    setState(() => _loadingCount = true);
    try {
      final data = await SupabaseService.getEmergencyContactsFull();
      if (mounted) setState(() => _contactCount = data.length);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingCount = false);
    }
  }

  Future<void> _loadSafetyPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _locationSharingDuration =
            prefs.getString('safety_location_duration') ?? '30 minutos';
        _geofenceRadius =
            prefs.getString('safety_geofence_radius') ?? '500m';
      });
    }
  }

  Future<void> _saveSafetyPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void _showDurationDialog() {
    const options = ['15 minutos', '30 minutos', '1 hora', 'Hasta cancelar'];
    String selected = _locationSharingDuration;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Duración de Compartir Ubicación'),
          content: RadioGroup<String>(
            groupValue: selected,
            onChanged: (v) { if (v != null) setLocal(() => selected = v); },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map((o) => RadioListTile<String>(value: o, title: Text(o)))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _locationSharingDuration = selected);
                _saveSafetyPref('safety_location_duration', selected);
                Navigator.pop(ctx);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRadiusDialog() {
    const options = ['100m', '500m', '1km', '2km'];
    String selected = _geofenceRadius;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text('Radio de Geocerca'),
          content: RadioGroup<String>(
            groupValue: selected,
            onChanged: (v) { if (v != null) setLocal(() => selected = v); },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: options
                  .map((o) => RadioListTile<String>(value: o, title: Text(o)))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _geofenceRadius = selected);
                _saveSafetyPref('safety_geofence_radius', selected);
                Navigator.pop(ctx);
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Configuración de Seguridad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // ── Contactos de emergencia → pantalla dedicada ───
          InkWell(
            onTap: () async {
              await Navigator.pushNamed(context, AppRoutes.emergencyContacts);
              _loadContactCount();
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  _SettingIcon(
                    iconName: 'contacts',
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contactos de Emergencia',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _loadingCount
                              ? 'Cargando...'
                              : '$_contactCount contacto${_contactCount != 1 ? 's' : ''} configurado${_contactCount != 1 ? 's' : ''} (FCM / WhatsApp)',
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

          // ── Duración compartir ubicación ─────────────────
          InkWell(
            onTap: _showDurationDialog,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  _SettingIcon(
                    iconName: 'schedule',
                    color: theme.colorScheme.primary,
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

          // ── Radio geocerca ───────────────────────────────
          InkWell(
            onTap: _showRadiusDialog,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  _SettingIcon(
                    iconName: 'radar',
                    color: theme.colorScheme.primary,
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
}

// ── Widgets auxiliares ────────────────────────────────────────────

class _SettingIcon extends StatelessWidget {
  final String iconName;
  final Color color;
  const _SettingIcon({required this.iconName, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CustomIconWidget(iconName: iconName, color: color, size: 20),
      ),
    );
  }
}
