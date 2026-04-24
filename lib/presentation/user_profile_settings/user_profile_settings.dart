import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/accessibility_section_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_preferences_widget.dart';
import './widgets/data_export_widget.dart';
import './widgets/language_section_widget.dart';
import './widgets/notification_section_widget.dart';
import './widgets/privacy_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/panic_button_settings_widget.dart';
import './widgets/safety_section_widget.dart';
import './widgets/verification_section_widget.dart';

class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  Map<String, dynamic> _userData = {};
  bool _isLoading = true;
  bool _isSigningOut = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseService.ensureUserProfile();
      final userId = SupabaseService.currentUserId;
      if (userId != null) {
        final profile = await SupabaseService.getUserProfile(userId);
        if (mounted) {
          setState(() {
            _userData = profile != null
                ? _normalizeProfile(profile)
                : _fallbackFromAuth();
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _userData = _fallbackFromAuth());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _normalizeProfile(Map<String, dynamic> p) {
    final user = SupabaseService.currentUser;
    return {
      'name': p['full_name'] ?? user?.userMetadata?['full_name'] ?? 'Usuario',
      'email': p['email'] ?? user?.email ?? '',
      'phone': p['phone'] ?? user?.userMetadata?['phone'] ?? '',
      'role': _localizeRole(p['role'] as String? ?? 'citizen'),
      'avatar': p['avatar_url'] ?? '',
      'semanticLabel': 'Foto de perfil',
      'reputationScore':
          (p['reputation_score'] as num?)?.toDouble() ?? 0.0,
      'totalReports': (p['total_reports'] as num?)?.toInt() ?? 0,
      'verifiedPhone': p['is_phone_verified'] ?? false,
      'verifiedEmail': p['is_email_verified'] ?? false,
      'verifiedDocuments': p['is_documents_verified'] ?? false,
    };
  }

  Map<String, dynamic> _fallbackFromAuth() {
    final user = SupabaseService.currentUser;
    return {
      'name': user?.userMetadata?['full_name'] ?? 'Usuario',
      'email': user?.email ?? '',
      'phone': user?.userMetadata?['phone'] ?? '',
      'role': _localizeRole(
        user?.userMetadata?['role'] as String? ?? 'citizen',
      ),
      'avatar': '',
      'semanticLabel': 'Foto de perfil',
      'reputationScore': 0.0,
      'totalReports': 0,
      'verifiedPhone': false,
      'verifiedEmail': user?.emailConfirmedAt != null,
      'verifiedDocuments': false,
    };
  }

  String _localizeRole(String role) {
    switch (role) {
      case 'authority':
        return 'Autoridad';
      case 'ngo_representative':
        return 'Representante ONG';
      default:
        return 'Ciudadano';
    }
  }

  Future<void> _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSigningOut = true);
    try {
      await SupabaseService.signOut();
      if (mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSigningOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cerrar sesión. Intenta de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'arrow_back',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
                SizedBox(width: 4.w),
                Text(
                  'Configuración de Perfil',
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ProfileHeaderWidget(userData: _userData),
                      SizedBox(height: 2.h),
                      AccountSectionWidget(userData: _userData),
                      SizedBox(height: 2.h),
                      PrivacySectionWidget(),
                      SizedBox(height: 2.h),
                      NotificationSectionWidget(),
                      SizedBox(height: 2.h),
                      SafetySectionWidget(),
                      SizedBox(height: 2.h),
                      PanicButtonSettingsWidget(),
                      SizedBox(height: 2.h),
                      LanguageSectionWidget(),
                      SizedBox(height: 2.h),
                      AccessibilitySectionWidget(),
                      SizedBox(height: 2.h),
                      AppPreferencesWidget(),
                      SizedBox(height: 2.h),
                      VerificationSectionWidget(userData: _userData),
                      SizedBox(height: 2.h),
                      DataExportWidget(),
                      SizedBox(height: 3.h),

                      // Sign-out button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed:
                                _isSigningOut ? null : _handleSignOut,
                            icon: _isSigningOut
                                ? SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.error,
                                    ),
                                  )
                                : CustomIconWidget(
                                    iconName: 'logout',
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                            label: Text(
                              _isSigningOut
                                  ? 'Cerrando sesión...'
                                  : 'Cerrar Sesión',
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
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
