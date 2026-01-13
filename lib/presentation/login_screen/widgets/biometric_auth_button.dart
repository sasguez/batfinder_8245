import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Biometric authentication button widget
/// Provides Face ID/Touch ID on iOS, Fingerprint/Face on Android
class BiometricAuthButton extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const BiometricAuthButton({super.key, required this.onAuthenticated});

  @override
  State<BiometricAuthButton> createState() => _BiometricAuthButtonState();
}

class _BiometricAuthButtonState extends State<BiometricAuthButton> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (mounted) {
        setState(() {
          _canCheckBiometrics = canCheck && isDeviceSupported;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _canCheckBiometrics = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_canCheckBiometrics || _isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Autentícate para acceder a BatFinder',
      );

      if (authenticated) {
        HapticFeedback.mediumImpact();
        widget.onAuthenticated();
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error de autenticación: ${e.message ?? "Desconocido"}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_canCheckBiometrics) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 2.h),
      child: OutlinedButton.icon(
        onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
        icon: _isAuthenticating
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
            : CustomIconWidget(
                iconName: 'fingerprint',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
        label: Text(
          _isAuthenticating ? 'Autenticando...' : 'Usar Biometría',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.8.h),
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}