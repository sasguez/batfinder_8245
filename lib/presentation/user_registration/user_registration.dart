import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/basic_info_section_widget.dart';
import './widgets/biometric_enrollment_widget.dart';
import './widgets/role_selection_section_widget.dart';
import './widgets/role_specific_section_widget.dart';
import './widgets/success_animation_widget.dart';
import './widgets/terms_acceptance_widget.dart';

/// User Registration Screen
/// Enables new users to create accounts with role-based profile setup
/// optimized for Colombian safety requirements
class UserRegistration extends StatefulWidget {
  const UserRegistration({super.key});

  @override
  State<UserRegistration> createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _organizationController = TextEditingController();

  // Form state
  String _selectedRole = 'Citizen';
  String? _selectedMunicipality;
  String? _badgePhotoPath;
  bool _termsAccepted = false;
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showSuccessAnimation = false;
  bool _showEmailVerificationModal = false;
  double _passwordStrength = 0.0;

  // Biometric state
  bool _biometricAvailable = false;
  bool _biometricEnrolled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
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

  void _checkBiometricAvailability() {
    // Simulate biometric check
    setState(() {
      _biometricAvailable = true;
    });
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    double strength = 0.0;

    if (password.length >= 8) strength += 0.25;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.25;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
    });
  }

  bool _isFormValid() {
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        !_termsAccepted) {
      return false;
    }

    if (_selectedRole == 'Citizen' && _selectedMunicipality == null) {
      return false;
    }

    if (_selectedRole == 'Authority' && _badgePhotoPath == null) {
      return false;
    }

    if (_selectedRole == 'NGO Representative' &&
        _organizationController.text.isEmpty) {
      return false;
    }

    return true;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate() || !_isFormValid()) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.mediumImpact();

    // Simulate registration API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Check for duplicate account error (simulated)
    if (_emailController.text == 'duplicate@example.com') {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An account with this email already exists'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show biometric enrollment if available
    if (_biometricAvailable && !_biometricEnrolled) {
      _showBiometricEnrollmentDialog();
    } else {
      _showEmailVerification();
    }
  }

  void _showBiometricEnrollmentDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BiometricEnrollmentWidget(
        onEnroll: () {
          setState(() {
            _biometricEnrolled = true;
          });
          Navigator.pop(context);
          _showEmailVerification();
        },
        onSkip: () {
          Navigator.pop(context);
          _showEmailVerification();
        },
      ),
    );
  }

  void _showEmailVerification() {
    setState(() {
      _showEmailVerificationModal = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Verify Your Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'email',
              color: Theme.of(context).colorScheme.primary,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'We\'ve sent a verification email to ${_emailController.text}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Text(
              'Please check your inbox and click the verification link to activate your account.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Verification email resent')),
              );
            },
            child: Text('Resend Email'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessAndNavigate();
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAndNavigate() {
    setState(() {
      _showSuccessAnimation = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessAnimationWidget(
        onComplete: () {
          Navigator.pop(context);
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushReplacementNamed('/onboarding-flow');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_fullNameController.text.isNotEmpty ||
            _emailController.text.isNotEmpty ||
            _phoneController.text.isNotEmpty ||
            _passwordController.text.isNotEmpty) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Discard Changes?'),
              content: Text('Your registration progress will be lost.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Discard'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text('Create Account'),
          centerTitle: false,
          leading: IconButton(
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color:
                  theme.appBarTheme.iconTheme?.color ??
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
                // Header
                Text(
                  'Join BatFinder',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Create your account to help make Colombia safer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),

                // Basic Information Section
                BasicInfoSectionWidget(
                  fullNameController: _fullNameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  showPassword: _showPassword,
                  passwordStrength: _passwordStrength,
                  onTogglePassword: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                SizedBox(height: 3.h),

                // Role Selection Section
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

                // Role-Specific Section
                RoleSpecificSectionWidget(
                  selectedRole: _selectedRole,
                  selectedMunicipality: _selectedMunicipality,
                  badgePhotoPath: _badgePhotoPath,
                  organizationController: _organizationController,
                  onMunicipalityChanged: (municipality) {
                    setState(() {
                      _selectedMunicipality = municipality;
                    });
                  },
                  onBadgePhotoSelected: (path) {
                    setState(() {
                      _badgePhotoPath = path;
                    });
                  },
                ),
                SizedBox(height: 3.h),

                // Terms Acceptance
                TermsAcceptanceWidget(
                  termsAccepted: _termsAccepted,
                  onChanged: (value) {
                    setState(() {
                      _termsAccepted = value ?? false;
                    });
                  },
                ),
                SizedBox(height: 4.h),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isFormValid() && !_isLoading
                        ? _handleRegistration
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.12),
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
                                theme.colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 2.h),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(
                          context,
                          rootNavigator: true,
                        ).pushReplacementNamed('/login-screen');
                      },
                      child: Text('Sign In'),
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
