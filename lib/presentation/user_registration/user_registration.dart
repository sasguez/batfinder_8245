import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/basic_info_section_widget.dart';
import './widgets/biometric_enrollment_widget.dart';
import './widgets/role_selection_section_widget.dart';
import './widgets/role_specific_section_widget.dart';
import './widgets/success_animation_widget.dart';
import './widgets/terms_acceptance_widget.dart';

class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationController = TextEditingController();

  String _selectedRole = 'Citizen';
  String? _selectedMunicipality;
  String? _badgePhotoPath;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _showPassword = false;
  double _passwordStrength = 0.0;

  bool _biometricAvailable = false;
  bool _biometricEnrolled = false;

  @override
  void initState() {
    super.initState();
    _biometricAvailable = true;
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _organizationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    final p = _passwordController.text;
    double s = 0.0;
    if (p.length >= 8) { s += 0.25; }
    if (p.contains(RegExp(r'[A-Z]'))) { s += 0.25; }
    if (p.contains(RegExp(r'[0-9]'))) { s += 0.25; }
    if (p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) { s += 0.25; }
    setState(() => _passwordStrength = s);
  }

  bool _isFormValid() {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        !_termsAccepted) return false;
    if (_selectedRole == 'Citizen' && _selectedMunicipality == null) return false;
    if (_selectedRole == 'Authority' && _badgePhotoPath == null) return false;
    if (_selectedRole == 'NGO Representative' &&
        _organizationController.text.isEmpty) return false;
    return true;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || !_isFormValid()) {
      HapticFeedback.mediumImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Completa todos los campos requeridos'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      await SupabaseService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        metadata: {
          'full_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _selectedRole.toLowerCase().replaceAll(' ', '_'),
        },
      );

      if (!mounted) return;

      if (_biometricAvailable && !_biometricEnrolled) {
        _showBiometricEnrollmentDialog();
      } else {
        _showSuccessAndNavigate();
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('already registered')
          ? 'Ya existe una cuenta con este correo.'
          : 'Error al registrarse. Intenta de nuevo.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showBiometricEnrollmentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiometricEnrollmentWidget(
        onEnroll: () {
          setState(() => _biometricEnrolled = true);
          Navigator.pop(context);
          _showSuccessAndNavigate();
        },
        onSkip: () {
          Navigator.pop(context);
          _showSuccessAndNavigate();
        },
      ),
    );
  }

  void _showSuccessAndNavigate() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessAnimationWidget(
        onComplete: () {
          Navigator.pop(context);
          Navigator.of(context, rootNavigator: true)
              .pushReplacementNamed(AppRoutes.alertDashboard);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final hasData = _fullNameController.text.isNotEmpty ||
            _emailController.text.isNotEmpty ||
            _phoneController.text.isNotEmpty ||
            _passwordController.text.isNotEmpty;
        if (!hasData) {
          if (mounted) { Navigator.pop(context); }
          return;
        }
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('¿Descartar cambios?'),
            content: const Text('Tu progreso de registro se perderá.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Descartar'),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) { Navigator.pop(context); }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Crear Cuenta'),
          centerTitle: false,
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: theme.appBarTheme.iconTheme?.color ??
                  theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                Text(
                  'Únete a BatFinder',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Crea tu cuenta para contribuir a la seguridad de Colombia',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),

                BasicInfoSectionWidget(
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  showPassword: _showPassword,
                  passwordStrength: _passwordStrength,
                  onTogglePassword: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
                SizedBox(height: 3.h),

                RoleSelectionSectionWidget(
                  selectedRole: _selectedRole,
                  onRoleChanged: (role) {
                    setState(() {
                      _selectedRole = role;
                      _selectedMunicipality = null;
                      _badgePhotoPath = null;
                      _organizationController.clear();
                    });
                  },
                ),
                SizedBox(height: 3.h),

                RoleSpecificSectionWidget(
                  selectedRole: _selectedRole,
                  selectedMunicipality: _selectedMunicipality,
                  badgePhotoPath: _badgePhotoPath,
                  organizationController: _organizationController,
                  onMunicipalityChanged: (m) =>
                      setState(() => _selectedMunicipality = m),
                  onBadgePhotoSelected: (p) =>
                      setState(() => _badgePhotoPath = p),
                ),
                SizedBox(height: 3.h),

                TermsAcceptanceWidget(
                  termsAccepted: _termsAccepted,
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v ?? false),
                ),
                SizedBox(height: 4.h),

                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed:
                        _isFormValid() && !_isLoading ? _handleRegistration : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor:
                          theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.onPrimary),
                            ),
                          )
                        : Text(
                            'Crear Cuenta',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 2.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context, rootNavigator: true)
                            .pushReplacementNamed(AppRoutes.login);
                      },
                      child: const Text('Iniciar Sesión'),
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
