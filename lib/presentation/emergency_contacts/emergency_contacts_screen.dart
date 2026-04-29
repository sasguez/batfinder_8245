import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../services/supabase_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/countries.dart';

import '../../widgets/custom_icon_widget.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await SupabaseService.getEmergencyContactsFull();
      if (mounted) setState(() => _contacts = data);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error al cargar contactos: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(Map<String, dynamic> contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar contacto'),
        content: Text('¿Eliminar a ${contact['name']} de tus Contactos de Emergencia?'),
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
    if (confirmed != true) return;

    try {
      await SupabaseService.deleteEmergencyContact(contact['id'] as String);
      if (mounted) {
        setState(() => _contacts.removeWhere((c) => c['id'] == contact['id']));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    }
  }

  Future<void> _openForm({Map<String, dynamic>? contact}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ContactForm(
        contact: contact,
        onSaved: (data) async {
          if (contact == null) {
            try {
              final added = await SupabaseService.addEmergencyContactFull(
                name:          data['name']! as String,
                phoneWa:       data['phone_wa'] as String?,
                phoneSms:      data['phone_sms'] as String?,
                hasApp:        data['has_app'] as bool,
                fcmToken:      data['fcm_token'] as String?,
                priority:      data['priority'] as int,
                whatsappOptin: data['whatsapp_optin'] as bool,
              );
              if (mounted) setState(() => _contacts.add(added));
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error al guardar: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          } else {
            try {
              await SupabaseService.updateEmergencyContactFull(
                contactId: contact['id'] as String,
                updates: {
                  'name':           data['name'],
                  'phone_wa':       data['phone_wa'],
                  'phone_sms':      data['phone_sms'],
                  'has_app':        data['has_app'],
                  'fcm_token':      data['fcm_token'],
                  'priority':       data['priority'],
                  'whatsapp_optin': data['whatsapp_optin'],
                },
              );
              if (mounted) {
                setState(() {
                  final idx =
                      _contacts.indexWhere((c) => c['id'] == contact['id']);
                  if (idx != -1) _contacts[idx] = {...contact, ...data};
                });
              }
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Error al actualizar: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Contactos de Emergencia'),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        tooltip: 'Agregar contacto',
        child: const CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _load);
    }
    if (_contacts.isEmpty) {
      return _EmptyView(onAdd: () => _openForm());
    }
    return _buildList();
  }

  Widget _buildList() {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 10.h),
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => SizedBox(height: 1.h),
      itemBuilder: (ctx, i) => _ContactCard(
        contact:  _contacts[i],
        onEdit:   () => _openForm(contact: _contacts[i]),
        onDelete: () => _delete(_contacts[i]),
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────

class _ContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactCard({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme        = Theme.of(context);
    final hasApp       = contact['has_app']        as bool? ?? false;
    final waOptin      = contact['whatsapp_optin'] as bool? ?? false;
    final priority     = contact['priority']       as int?  ?? 1;
    final phoneWa      = contact['phone_wa']       as String?;
    final phoneSms     = contact['phone_sms']      as String?;

    return Slidable(
      key:        ValueKey(contact['id']),
      endActionPane: ActionPane(
        motion:      const DrawerMotion(),
        extentRatio: 0.28,
        children: [
          SlidableAction(
            onPressed:    (_) => onDelete(),
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            icon:         Icons.delete_outline,
            label:        'Eliminar',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color:        theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: theme.dividerColor),
        ),
        child: ListTile(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: CircleAvatar(
            radius: 20,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              (contact['name'] as String).substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color:      theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            contact['name'] as String,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 0.5.h),
              if (phoneWa != null)
                Text('WA: $phoneWa',
                    style: theme.textTheme.bodySmall),
              if (phoneSms != null)
                Text('SMS: $phoneSms',
                    style: theme.textTheme.bodySmall),
              SizedBox(height: 0.5.h),
              Wrap(
                spacing: 1.w,
                children: [
                  _Badge(
                    label: 'P$priority',
                    color: theme.colorScheme.primary,
                  ),
                  if (hasApp)
                    _Badge(
                      label: 'FCM',
                      color: theme.colorScheme.secondary,
                    ),
                  if (waOptin)
                    _Badge(
                      label: 'WhatsApp',
                      color: theme.colorScheme.tertiary,
                    ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: onEdit,
            icon: CustomIconWidget(
              iconName: 'edit',
              color:    theme.colorScheme.primary,
              size:     20,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color:      color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Empty & Error views ───────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'contacts',
              color:    theme.colorScheme.onSurfaceVariant,
              size:     56,
            ),
            SizedBox(height: 2.h),
            Text(
              'Sin Contactos de Emergencia',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Agrega personas que serán notificadas\npor FCM o WhatsApp al activar el pánico.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon:  const Icon(Icons.add),
              label: const Text('Agregar primer contacto'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color:    theme.colorScheme.error,
              size:     48,
            ),
            SizedBox(height: 2.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            SizedBox(height: 2.h),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon:  const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form (bottom sheet) ───────────────────────────────────────────────

class _ContactForm extends StatefulWidget {
  final Map<String, dynamic>? contact;
  final Future<void> Function(Map<String, dynamic>) onSaved;

  const _ContactForm({this.contact, required this.onSaved});

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _searchCtrl;

  // Números completos con código de país (ej: +573001234567)
  String _phoneWaComplete = '';
  String _phoneSmsComplete = '';

  // Valores iniciales para IntlPhoneField al editar
  String _initialWaCountry  = 'CO';
  String _initialSmsCountry = 'CO';
  String _initialWaNumber   = '';
  String _initialSmsNumber  = '';

  bool    _hasApp          = false;
  bool    _waOptin         = false;
  int     _priority        = 1;
  bool    _saving          = false;
  String? _fetchedFcmToken;
  bool    _isLookingUp     = false;
  bool    _lookupAttempted = false;
  String? _foundUserName;

  @override
  void initState() {
    super.initState();
    final c          = widget.contact;
    _nameCtrl        = TextEditingController(text: c?['name'] as String? ?? '');
    _searchCtrl       = TextEditingController();
    _hasApp          = c?['has_app']        as bool? ?? false;
    _waOptin         = c?['whatsapp_optin'] as bool? ?? false;
    _priority        = c?['priority']       as int?  ?? 1;
    _fetchedFcmToken = c?['fcm_token']      as String?;

    final waRaw  = c?['phone_wa']  as String? ?? '';
    final smsRaw = c?['phone_sms'] as String? ?? '';

    _phoneWaComplete  = waRaw;
    _phoneSmsComplete = smsRaw;

    final deviceCountry =
        SchedulerBinding.instance.platformDispatcher.locale.countryCode ?? 'CO';
    _initialWaCountry  = _detectCountry(waRaw, deviceCountry);
    _initialSmsCountry = _detectCountry(smsRaw, deviceCountry);
    _initialWaNumber   = _stripKnownDialCode(waRaw, _initialWaCountry);
    _initialSmsNumber  = _stripKnownDialCode(smsRaw, _initialSmsCountry);
  }

  // Elimina el prefijo +CC para mostrar solo el número local en el campo
  String _stripKnownDialCode(String full, String countryCode) {
    if (full.isEmpty || !full.startsWith('+')) return full;
    try {
      final dial = countries.firstWhere((c) => c.code == countryCode).dialCode;
      if (full.startsWith('+$dial')) return full.substring(1 + dial.length);
    } catch (_) {}
    return full;
  }

  String _detectCountry(String fullNumber, String fallback) {
    if (fullNumber.isEmpty || !fullNumber.startsWith('+')) return fallback;
    final withoutPlus = fullNumber.substring(1);
    final sorted = [...countries]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final c in sorted) {
      if (withoutPlus.startsWith(c.dialCode)) return c.code;
    }
    return fallback;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final v = value.trim();
    if (v.startsWith('@')) {
      final nick = v.substring(1);
      if (nick.isEmpty) return 'Escribe un nickname despues de @';
      if (nick.length < 3) return 'El nickname debe tener minimo 3 caracteres';
      if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(nick)) {
        return 'Solo letras, numeros y guion bajo (_)';
      }
      return null;
    } else if (v.contains('@')) {
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v)) {
        return 'Correo electronico no valido';
      }
      return null;
    } else {
      if (!v.startsWith('+')) {
        return 'Telefono debe iniciar con + (ej: +573001234567)';
      }
      if (v.length < 8) return 'Numero de telefono muy corto';
      return null;
    }
  }

  Future<void> _lookupUser() async {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _isLookingUp     = true;
      _lookupAttempted = true;
      _foundUserName   = null;
    });
    final result = await SupabaseService.lookupUserForFCM(query);
    if (!mounted) return;
    setState(() {
      _fetchedFcmToken = result?['fcm_token'] as String?;
      if (result != null) {
        final name     = result['full_name'] as String? ?? '';
        final nickname = result['nickname']  as String?;
        _foundUserName = nickname != null ? '$name (@$nickname)' : name;
      }
      _isLookingUp = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _saving = true);
    await widget.onSaved({
      'name':           _nameCtrl.text.trim(),
      'phone_wa':       _phoneWaComplete.isEmpty ? null : _phoneWaComplete,
      'phone_sms':      _phoneSmsComplete.isEmpty ? null : _phoneSmsComplete,
      'has_app':        _hasApp,
      'fcm_token':      _hasApp ? _fetchedFcmToken : null,
      'whatsapp_optin': _waOptin,
      'priority':       _priority,
    });
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme  = Theme.of(context);
    final isEdit = widget.contact != null;

    return Padding(
      padding: EdgeInsets.only(
        left:   4.w,
        right:  4.w,
        top:    2.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 4.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize:       MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width:  10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color:        theme.colorScheme.outline.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                isEdit ? 'Editar Contacto' : 'Nuevo Contacto',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText:  'Nombre completo *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              SizedBox(height: 2.h),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Teléfono WhatsApp',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: _initialWaCountry,
                initialValue: _initialWaNumber,
                languageCode: 'es',
                searchText: 'Busca tu país...',
                onChanged: (phone) {
                  _phoneWaComplete = phone.completeNumber;
                },
                onSaved: (phone) {
                  if (phone != null) _phoneWaComplete = phone.completeNumber;
                },
              ),
              SizedBox(height: 2.h),
              IntlPhoneField(
                decoration: const InputDecoration(
                  labelText: 'Teléfono SMS (opcional)',
                  border: OutlineInputBorder(),
                ),
                initialCountryCode: _initialSmsCountry,
                initialValue: _initialSmsNumber,
                languageCode: 'es',
                searchText: 'Busca tu pais...',
                onChanged: (phone) {
                  _phoneSmsComplete = phone.completeNumber;
                },
                onSaved: (phone) {
                  if (phone != null) _phoneSmsComplete = phone.completeNumber;
                },
                validator: (_) => null, // SMS es opcional
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title:    const Text('Tiene BatFinder instalado'),
                subtitle: const Text('Recibirá notificaciones push (FCM)'),
                value:    _hasApp,
                onChanged: (v) => setState(() {
                  _hasApp = v;
                  if (!v) {
                    _fetchedFcmToken = null;
                    _foundUserName   = null;
                    _searchCtrl.clear();
                    _lookupAttempted = false;
                  }
                }),
              ),
              if (_hasApp) ...[
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Buscar usuario en BatFinder',
                    prefixIcon: Icon(Icons.manage_search_outlined),
                    hintText: '@nickname, correo@ejemplo.com o +573001234567',
                    helperText: 'Busca por @nickname, correo o telefono con codigo de pais',
                    helperMaxLines: 2,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateSearchQuery,
                ),
                SizedBox(height: 1.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isLookingUp ? null : _lookupUser,
                    icon: _isLookingUp
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.search, size: 18),
                    label: Text(
                      _isLookingUp ? 'Buscando...' : 'Buscar usuario',
                    ),
                  ),
                ),
                SizedBox(height: 0.8.h),
                if (_fetchedFcmToken != null)
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: theme.colorScheme.secondary, size: 16),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          _foundUserName != null
                              ? 'Push activo - $_foundUserName'
                              : 'Notificacion push habilitada',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  )
                else if (_lookupAttempted)
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: theme.colorScheme.onSurfaceVariant, size: 16),
                      SizedBox(width: 1.w),
                      Text(
                        'Usuario no encontrado en BatFinder',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
              ],
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title:    const Text('Opt-in WhatsApp'),
                subtitle: const Text(
                  'Aceptó recibir mensajes del Sandbox de Twilio',
                ),
                value:    _waOptin,
                onChanged: (v) => setState(() => _waOptin = v),
              ),
              Row(
                children: [
                  Text('Prioridad:', style: theme.textTheme.bodyMedium),
                  SizedBox(width: 3.w),
                  DropdownButton<int>(
                    value: _priority,
                    items: [1, 2, 3, 4, 5]
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text('$v'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _priority = v ?? 1),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    '(1 = más urgente)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width:  20,
                          child:  CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isEdit ? 'Actualizar' : 'Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
