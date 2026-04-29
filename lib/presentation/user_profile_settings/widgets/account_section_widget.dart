import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class AccountSectionWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isGoogleUser;
  final VoidCallback onProfileUpdated;

  const AccountSectionWidget({
    super.key,
    required this.userData,
    required this.isGoogleUser,
    required this.onProfileUpdated,
  });

  @override
  State<AccountSectionWidget> createState() => _AccountSectionWidgetState();
}

class _AccountSectionWidgetState extends State<AccountSectionWidget> {
  Future<void> _editName() async {
    final controller = TextEditingController(
      text: widget.userData['name'] as String? ?? '',
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre completo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newName == null || newName.isEmpty || !mounted) return;
    try {
      await SupabaseService.updateUserProfile(
        userId: SupabaseService.currentUserId!,
        updates: {'full_name': newName},
      );
      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al actualizar nombre'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      if (kDebugMode) print('❌ Edit name error: $e');
    }
  }

  Future<void> _editPhone() async {
    final controller = TextEditingController(
      text: widget.userData['phone'] as String? ?? '',
    );
    final newPhone = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Teléfono'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Número de teléfono',
            hintText: '+57 300 000 0000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (newPhone == null || !mounted) return;
    try {
      await SupabaseService.updateUserProfile(
        userId: SupabaseService.currentUserId!,
        updates: {'phone': newPhone},
      );
      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al actualizar teléfono'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      if (kDebugMode) print('❌ Edit phone error: $e');
    }
  }
  Future<void> _editNickname() async {
    final current = (widget.userData['nickname'] as String?) ?? '';
    final controller = TextEditingController(text: current);
    String? errorMsg;
    bool isChecking = false;

    final newNickname = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Editar Nickname'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Nickname',
                  prefixText: '@',
                  hintText: 'usuario_123',
                  errorText: errorMsg,
                ),
                onChanged: (_) => setDialogState(() => errorMsg = null),
              ),
              SizedBox(height: 1.h),
              Text(
                'Solo letras, numeros y _ · 3-20 caracteres',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              if (isChecking) ...[
                SizedBox(height: 1.h),
                const LinearProgressIndicator(),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: isChecking
                  ? null
                  : () async {
                      final value = controller.text.trim().toLowerCase();
                      if (value.length < 3 || value.length > 20) {
                        setDialogState(
                          () => errorMsg = 'Entre 3 y 20 caracteres',
                        );
                        return;
                      }
                      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
                        setDialogState(
                          () => errorMsg = 'Solo letras, numeros y _',
                        );
                        return;
                      }
                      setDialogState(() => isChecking = true);
                      final available =
                          await SupabaseService.checkNicknameAvailable(value);
                      if (!ctx.mounted) return;
                      if (!available) {
                        setDialogState(() {
                          errorMsg = 'Este nickname ya esta en uso';
                          isChecking = false;
                        });
                        return;
                      }
                      Navigator.pop(ctx, value);
                    },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    if (newNickname == null || !mounted) return;
    try {
      await SupabaseService.updateUserProfile(
        userId: SupabaseService.currentUserId!,
        updates: {'nickname': newNickname},
      );
      widget.onProfileUpdated();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Error al actualizar nickname'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      if (kDebugMode) print('Edit nickname error: $e');
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
              'Información de Cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Divider(height: 1, thickness: 1),
          _buildInfoTile(
            context: context,
            icon: 'person',
            label: 'Nombre',
            value: widget.userData['name'] as String? ?? '',
            onTap: _editName,
          ),
          Divider(height: 1, thickness: 1, indent: 16.w),
          _buildInfoTile(
            context: context,
            icon: 'alternate_email',
            label: 'Nickname',
            value: (widget.userData['nickname'] as String?)?.isNotEmpty == true
                ? '@${widget.userData['nickname']}'
                : 'Sin nickname',
            onTap: _editNickname,
          ),
          Divider(height: 1, thickness: 1, indent: 16.w),
          _buildInfoTile(
            context: context,
            icon: 'email',
            label: 'Correo Electrónico',
            value: widget.userData['email'] as String? ?? '',
            onTap: widget.isGoogleUser ? null : () {},
            disabled: widget.isGoogleUser,
          ),
          Divider(height: 1, thickness: 1, indent: 16.w),
          _buildInfoTile(
            context: context,
            icon: 'phone',
            label: 'Teléfono',
            value: (widget.userData['phone'] as String?)?.isNotEmpty == true
                ? widget.userData['phone'] as String
                : 'Sin número',
            onTap: _editPhone,
          ),
          Divider(height: 1, thickness: 1, indent: 16.w),
          _buildInfoTile(
            context: context,
            icon: 'lock',
            label: 'Contraseña',
            value: '••••••••',
            onTap: widget.isGoogleUser ? null : () {},
            disabled: widget.isGoogleUser,
            disabledHint: widget.isGoogleUser ? 'Gestionada por Google' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required VoidCallback? onTap,
    bool disabled = false,
    String? disabledHint,
  }) {
    final theme = Theme.of(context);

    final tile = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: disabled
                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.08)
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: disabled
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color:
                          disabled ? theme.colorScheme.onSurfaceVariant : null,
                    ),
                  ),
                  if (disabledHint != null) ...[
                    SizedBox(height: 0.3.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'lock',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 11,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          disabledHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!disabled)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              )
            else
              CustomIconWidget(
                iconName: 'block',
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 18,
              ),
          ],
        ),
      ),
    );

    if (disabled) return Opacity(opacity: 0.55, child: tile);
    return tile;
  }
}
