import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../services/supabase_service.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Safety Section Widget
/// Gestión de contactos de emergencia reales (Supabase) + preferencias de seguridad.
class SafetySectionWidget extends StatefulWidget {
  const SafetySectionWidget({super.key});

  @override
  State<SafetySectionWidget> createState() => _SafetySectionWidgetState();
}

class _SafetySectionWidgetState extends State<SafetySectionWidget> {
  static const int _maxContacts = 5;

  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _locationSharingDuration = '30 minutos';
  String _geofenceRadius = '500m';

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadSafetyPreferences();
  }

  Future<void> _loadSafetyPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _locationSharingDuration =
            prefs.getString('safety_location_duration') ?? '30 minutos';
        _geofenceRadius = prefs.getString('safety_geofence_radius') ?? '500m';
      });
    }
  }

  Future<void> _saveSafetyPref(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await SupabaseService.getEmergencyContacts();
      if (mounted) setState(() => _contacts = data);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Error al cargar contactos');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddContactDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Contacto de Emergencia'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone_outlined),
                  hintText: '+57 300 000 0000',
                ),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: relationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Parentesco (opcional)',
                  prefixIcon: Icon(Icons.family_restroom_outlined),
                  hintText: 'Ej: Esposo, Mamá, Amigo',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(ctx);
              await _addContact(
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                relation: relationCtrl.text.trim(),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _addContact({
    required String name,
    required String phone,
    required String relation,
  }) async {
    try {
      final newContact = await SupabaseService.addEmergencyContact(
        name: name,
        phone: phone,
        relation: relation,
      );
      if (mounted) setState(() => _contacts.add(newContact));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar contacto: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text(
          '¿Eliminar a ${contact['name']} de tus contactos de emergencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteContact(contact);
    }
  }

  Future<void> _deleteContact(Map<String, dynamic> contact) async {
    try {
      await SupabaseService.deleteEmergencyContact(contact['id'] as String);
      if (mounted) {
        setState(
          () => _contacts.removeWhere((c) => c['id'] == contact['id']),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar contacto: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
              'Configuración de Seguridad',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Divider(height: 1, thickness: 1),

          // ── Contactos de emergencia ──────────────────────
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
                      '${_contacts.length}/$_maxContacts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),

                if (_isLoading)
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (_errorMessage != null)
                  _ErrorRetryRow(
                    message: _errorMessage!,
                    onRetry: _loadContacts,
                  )
                else if (_contacts.isEmpty)
                  _EmptyContactsHint()
                else
                  ..._contacts.map(
                    (contact) => _buildContactCard(context, contact),
                  ),

                SizedBox(height: 1.h),

                if (!_isLoading && _contacts.length < _maxContacts)
                  OutlinedButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    label: const Text('Agregar Contacto'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 6.h),
                    ),
                  ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          // ── Duración compartir ubicación ─────────────────
          InkWell(
            onTap: () => _showDurationDialog(context),
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
            onTap: () => _showRadiusDialog(context),
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

  Widget _buildContactCard(
    BuildContext context,
    Map<String, dynamic> contact,
  ) {
    final theme = Theme.of(context);
    final relation = contact['relation'] as String? ?? '';

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
                  contact['name'] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  relation.isNotEmpty
                      ? '$relation • ${contact['phone']}'
                      : contact['phone'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(contact),
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

  void _showDurationDialog(BuildContext context) {
    const options = ['15 minutos', '30 minutos', '1 hora', 'Hasta cancelar'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duración de Compartir Ubicación'),
        content: RadioGroup<String>(
          groupValue: _locationSharingDuration,
          onChanged: (v) {
            if (v != null) {
              setState(() => _locationSharingDuration = v);
              _saveSafetyPref('safety_location_duration', v);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => RadioListTile<String>(value: o, title: Text(o)))
                .toList(),
          ),
        ),
      ),
    );
  }

  void _showRadiusDialog(BuildContext context) {
    const options = ['100m', '500m', '1km', '2km'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Radio de Geocerca'),
        content: RadioGroup<String>(
          groupValue: _geofenceRadius,
          onChanged: (v) {
            if (v != null) {
              setState(() => _geofenceRadius = v);
              _saveSafetyPref('safety_geofence_radius', v);
              Navigator.pop(ctx);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: options
                .map((o) => RadioListTile<String>(value: o, title: Text(o)))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Widgets auxiliares locales ──────────────────────────────────

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

class _EmptyContactsHint extends StatelessWidget {
  const _EmptyContactsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Text(
        'Sin contactos. Agrega hasta 5 personas que serán notificadas en caso de emergencia.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ErrorRetryRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorRetryRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
