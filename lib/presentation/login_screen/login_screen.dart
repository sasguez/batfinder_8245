import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/biometric_auth_button.dart';
import './widgets/login_form_fields.dart';
import './widgets/remember_me_toggle.dart';
import './widgets/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await SupabaseService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.alertDashboard);
      }
    } catch (e) {
      if (mounted) _showErrorDialog('Correo o contraseña incorrectos.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBiometricAuth() {
    HapticFeedback.mediumImpact();
    Navigator.of(context, rootNavigator: true)
        .pushReplacementNamed(AppRoutes.alertDashboard);
  }

  void _handleEmergencyAccess() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Text('Acceso de Emergencia'),
          ],
        ),
        content: const Text(
          'El acceso de emergencia proporciona funcionalidad limitada sin autenticación completa. ¿Deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context, rootNavigator: true)
                  .pushReplacementNamed(AppRoutes.emergencyPanicMode);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    try {
      setState(() => _isLoading = true);
      await SupabaseService.signInWithGoogle();
      if (mounted) {
        Navigator.of(context, rootNavigator: true)
            .pushReplacementNamed(AppRoutes.alertDashboard);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error al conectar con Google. Intenta de nuevo.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de Autenticación'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2D1B6B), Color(0xFF0D0B1A)],
            stops: [0.3, 1.0],
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Logo
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'shield',
                      color: Colors.white,
                      size: 15.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                Text(
                  'BatFinder',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),

                Text(
                  'Seguridad Ciudadana en Colombia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                LoginFormFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  formKey: _formKey,
                ),
                SizedBox(height: 2.h),

                RememberMeToggle(
                  onChanged: (_) {},
                ),
                SizedBox(height: 3.h),

                // Iniciar sesión
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            'Iniciar Sesión',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 1.h),

                BiometricAuthButton(onAuthenticated: _handleBiometricAuth),
                SizedBox(height: 2.h),

                // Acceso de emergencia
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleEmergencyAccess,
                    icon: CustomIconWidget(
                      iconName: 'emergency',
                      color: Colors.red.shade300,
                      size: 6.w,
                    ),
                    label: Text(
                      'Acceso de Emergencia',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.red.shade300,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      side: BorderSide(color: Colors.red.shade300, width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                SocialLoginButtons(
                  onGoogleLogin: _handleGoogleLogin,
                ),
                SizedBox(height: 3.h),

                // Registro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Nuevo usuario? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true)
                          .pushNamed(AppRoutes.registration),
                      child: Text(
                        'Registrarse',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
