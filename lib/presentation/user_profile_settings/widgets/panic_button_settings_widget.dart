import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Widget de configuración para activación del modo pánico
/// mediante el botón de bloqueo del dispositivo.
/// Persiste la preferencia en SharedPreferences con la clave
/// 'power_button_required_taps'.
class PanicButtonSettingsWidget extends StatefulWidget {
  const PanicButtonSettingsWidget({super.key});

  @override
  State<PanicButtonSettingsWidget> createState() =>
      _PanicButtonSettingsWidgetState();
}

class _PanicButtonSettingsWidgetState extends State<PanicButtonSettingsWidget> {
  static const String _prefKey = 'power_button_required_taps';
  int _requiredTaps = 3;

  @override
  void initState() {
    super.initState();
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _requiredTaps = prefs.getInt(_prefKey) ?? 3;
      });
    }
  }

  Future<void> _saveTaps(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, value);
    if (mounted) setState(() => _requiredTaps = value);
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
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'power_settings_new',
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Activación por Botón de Bloqueo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'Pulsa el botón de bloqueo rápidamente para activar el modo pánico sin desbloquear el teléfono. Solo funciona con la app en primer plano.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Divider(height: 1, thickness: 1),
          RadioGroup<int>(
            groupValue: _requiredTaps,
            onChanged: (val) {
              if (val != null) _saveTaps(val);
            },
            child: Column(
              children: [
                RadioListTile<int>(
                  value: 2,
                  title: Text('Doble toque', style: theme.textTheme.bodyLarge),
                  subtitle: Text(
                    '2 pulsaciones rápidas del botón de bloqueo',
                    style: theme.textTheme.bodySmall,
                  ),
                  activeColor: theme.colorScheme.primary,
                ),
                RadioListTile<int>(
                  value: 3,
                  title: Text(
                    'Triple toque (recomendado)',
                    style: theme.textTheme.bodyLarge,
                  ),
                  subtitle: Text(
                    '3 pulsaciones rápidas — menor riesgo de activación accidental',
                    style: theme.textTheme.bodySmall,
                  ),
                  activeColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'En iOS puede haber mayor latencia en la detección. Los cambios se aplican al reiniciar la app.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
