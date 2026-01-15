import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/biometric_auth_button.dart';
import './widgets/login_form_fields.dart';
import './widgets/remember_me_toggle.dart';
import './widgets/social_login_buttons.dart';

/// Login Screen for BatFinder Colombian Safety App
/// Provides secure authentication with biometric support and emergency access
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
  bool _rememberMe = false;

  // Mock credentials for testing
  final Map<String, Map<String, String>> _mockUsers = {
    'citizen@batfinder.co': {
      'password': 'citizen123',
      'role': 'Ciudadano',
      'name': 'Juan Pérez',
    },
    'authority@batfinder.co': {
      'password': 'authority123',
      'role': 'Autoridad',
      'name': 'Oficial García',
    },
    'ngo@batfinder.co': {
      'password': 'ngo123',
      'role': 'ONG',
      'name': 'María Rodríguez',
    },
    '3001234567': {
      'password': 'phone123',
      'role': 'Ciudadano',
      'name': 'Carlos López',
    },
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Check mock credentials
    if (_mockUsers.containsKey(email)) {
      final user = _mockUsers[email]!;
      if (user['password'] == password) {
        // Successful login
        HapticFeedback.mediumImpact();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Bienvenido ${user['name']}! (${user['role']})'),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          // Navigate to Alert Dashboard
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushReplacementNamed('/alert-dashboard');
        }
      } else {
        // Invalid password
        if (mounted) {
          _showErrorDialog(
            'Contraseña incorrecta. Por favor intenta de nuevo.',
          );
        }
      }
    } else {
      // User not found
      if (mounted) {
        _showErrorDialog('Usuario no encontrado. Verifica tus credenciales.');
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
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

  void _handleBiometricAuth() {
    // Simulate successful biometric authentication
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('¡Autenticación biométrica exitosa!'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );

    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed('/alert-dashboard');
  }

  void _handleEmergencyAccess() {
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
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
              Navigator.of(
                context,
                rootNavigator: true,
              ).pushReplacementNamed('/emergency-panic-mode');
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

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Inicio de sesión con $provider próximamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Safety shield logo
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'shield',
                      color: theme.colorScheme.primary,
                      size: 15.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),

                // App title
                Text(
                  'BatFinder',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),

                Text(
                  'Seguridad Ciudadana en Colombia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),

                // Login form fields
                LoginFormFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                  formKey: _formKey,
                ),
                SizedBox(height: 2.h),

                // Remember me toggle
                RememberMeToggle(
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value;
                    });
                  },
                ),
                SizedBox(height: 3.h),

                // Sign in button
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
                                theme.colorScheme.onPrimary,
                              ),
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

                // Biometric authentication button
                BiometricAuthButton(onAuthenticated: _handleBiometricAuth),
                SizedBox(height: 2.h),

                // Emergency access button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleEmergencyAccess,
                    icon: CustomIconWidget(
                      iconName: 'emergency',
                      color: theme.colorScheme.error,
                      size: 6.w,
                    ),
                    label: Text(
                      'Acceso de Emergencia',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.8.h),
                      side: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),

                // Social login buttons
                SocialLoginButtons(
                  onGoogleLogin: () => _handleSocialLogin('Google'),
                  onFacebookLogin: () => _handleSocialLogin('Facebook'),
                ),
                SizedBox(height: 4.h),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Nuevo usuario? ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushNamed('/user-registration');
                      },
                      child: Text(
                        'Registrarse',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                // Demo Credentials Section for Testing
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 5.w,
                            color: Colors.blue.shade700,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Credenciales de Prueba',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      _buildDemoCredential(
                        'Ciudadano',
                        'ciudadano@batfinder.com',
                        'ciudadano123',
                        Colors.green,
                      ),
                      SizedBox(height: 1.h),
                      _buildDemoCredential(
                        'Autoridad',
                        'autoridad@policia.mx',
                        'autoridad123',
                        Colors.blue,
                      ),
                      SizedBox(height: 1.h),
                      _buildDemoCredential(
                        'ONG',
                        'contacto@seguridadciudadana.org',
                        'ong123',
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoCredential(
    String role,
    String email,
    String password,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                size: 4.w,
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  email,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 4.w, color: Colors.blue),
                onPressed: () {
                  // Copy email to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Email copiado: $email')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.lock_outline, size: 4.w, color: Colors.grey.shade600),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  password,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.copy, size: 4.w, color: Colors.blue),
                onPressed: () {
                  // Copy password to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Contraseña copiada: $password')),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
