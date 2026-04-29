import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/sound_service.dart';
import '../../../services/vibration_service.dart';
import '../../../widgets/custom_icon_widget.dart';

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
  String _selectedLanguage = 'es';
  bool _isAutoDetected = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedLanguage = prefs.getString('app_language');
    final autoDetected = savedLanguage == null;
    final language = savedLanguage ?? _detectLocaleLanguage();
    if (autoDetected) await prefs.setString('app_language', language);
    setState(() {
      _proximityWarnings = prefs.getBool('notif_proximity') ?? true;
      _communityUpdates = prefs.getBool('notif_community') ?? true;
      _emergencyBroadcasts = prefs.getBool('notif_emergency') ?? true;
      _authorityAnnouncements = prefs.getBool('notif_authority') ?? false;
      _soundEnabled = prefs.getBool('notif_sound') ?? true;
      _vibrationEnabled = prefs.getBool('notif_vibration') ?? true;
      _selectedLanguage = language;
      _isAutoDetected = autoDetected;
    });
  }

  String _detectLocaleLanguage() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    const supported = {'es', 'en'};
    return supported.contains(code) ? code : 'es';
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

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
              'Notificaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          _buildSwitchTile(
            context: context,
            icon: 'warning',
            label: 'Alertas de Proximidad',
            subtitle: 'Incidentes cerca de tu ubicación',
            value: _proximityWarnings,
            onChanged: (value) {
              setState(() => _proximityWarnings = value);
              _saveBool('notif_proximity', value);
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
              _saveBool('notif_community', value);
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
              _saveBool('notif_emergency', value);
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
              _saveBool('notif_authority', value);
            },
          ),

          Divider(height: 1, thickness: 1),

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
              _saveBool('notif_sound', value);
              if (value) SoundService().playTestSound();
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
              _saveBool('notif_vibration', value);
              if (value) VibrationService().testVibration();
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // Language picker
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
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
                      iconName: 'language',
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
                        'Idioma',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 0.4.h),
                      if (_isAutoDetected)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.3.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Auto-detectado',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 9.sp,
                            ),
                          ),
                        )
                      else
                        Text(
                          _selectedLanguage == 'es' ? 'Español' : 'English',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: 'es', child: Text('Español')),
                    DropdownMenuItem(value: 'en', child: Text('English')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedLanguage = val;
                        _isAutoDetected = false;
                      });
                      _saveString('app_language', val);
                    }
                  },
                ),
              ],
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
}
