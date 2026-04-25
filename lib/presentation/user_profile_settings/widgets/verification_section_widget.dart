import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Verification Section Widget
/// Muestra el estado de verificación de la cuenta y permite al usuario
/// verificar su correo electrónico. Para usuarios de Google el email
/// se considera verificado automáticamente.
class VerificationSectionWidget extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isGoogleUser;

  const VerificationSectionWidget({
    super.key,
    required this.userData,
    required this.isGoogleUser,
  });

  @override
  State<VerificationSectionWidget> createState() =>
      _VerificationSectionWidgetState();
}

class _VerificationSectionWidgetState
    extends State<VerificationSectionWidget> {
  bool _sendingEmail = false;

  Future<void> _sendEmailVerification() async {
    if (_sendingEmail) return;
    setState(() => _sendingEmail = true);
    try {
      final email = widget.userData['email'] as String? ?? '';
      await SupabaseService.resendVerificationEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Correo de verificación enviado. Revisa tu bandeja de entrada.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
          'No se pudo enviar el correo. Verifica que "Confirm email" esté habilitado en Supabase.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
      if (kDebugMode) print('❌ Resend verification error: $e');
    } finally {
      if (mounted) setState(() => _sendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Google: email siempre verificado, no mostrar teléfono
    final emailVerified =
        widget.isGoogleUser || (widget.userData['verifiedEmail'] as bool? ?? false);
    final phoneVerified = widget.userData['verifiedPhone'] as bool? ?? false;
    final docsVerified = widget.userData['verifiedDocuments'] as bool? ?? false;

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
              'Verificación de Cuenta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Teléfono: solo visible para usuarios no-Google
          if (!widget.isGoogleUser) ...[
            _buildTile(
              context: context,
              icon: 'phone',
              label: 'Teléfono',
              isVerified: phoneVerified,
              onTap: phoneVerified
                  ? null
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La verificación por SMS requiere configuración de proveedor SMS en Supabase.',
                          ),
                        ),
                      ),
            ),
            Divider(height: 1, thickness: 1, indent: 16.w),
          ],

          // Correo electrónico
          _buildTile(
            context: context,
            icon: 'email',
            label: 'Correo Electrónico',
            isVerified: emailVerified,
            loading: _sendingEmail,
            onTap: emailVerified ? null : _sendEmailVerification,
          ),
          Divider(height: 1, thickness: 1, indent: 16.w),

          // Documentos de identidad: siempre visible
          _buildTile(
            context: context,
            icon: 'badge',
            label: 'Documentos de Identidad',
            isVerified: docsVerified,
            onTap: docsVerified
                ? null
                : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Contacta al equipo de BatFinder para verificar tu identidad.',
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String icon,
    required String label,
    required bool isVerified,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isVerified
                    ? Colors.green.withValues(alpha: 0.1)
                    : theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: isVerified ? Colors.green : theme.colorScheme.error,
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
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: isVerified ? 'check_circle' : 'cancel',
                        color:
                            isVerified ? Colors.green : theme.colorScheme.error,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isVerified ? 'Verificado' : 'No verificado',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isVerified
                              ? Colors.green
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (loading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            else if (isVerified)
              CustomIconWidget(
                iconName: 'verified',
                color: Colors.green,
                size: 22,
              )
            else if (onTap != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 0.5.h,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Verificar',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
