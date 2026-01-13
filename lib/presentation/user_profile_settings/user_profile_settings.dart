import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/accessibility_section_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_preferences_widget.dart';
import './widgets/data_export_widget.dart';
import './widgets/language_section_widget.dart';
import './widgets/notification_section_widget.dart';
import './widgets/privacy_section_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/safety_section_widget.dart';
import './widgets/verification_section_widget.dart';

/// User Profile Settings Screen
/// Comprehensive account management and safety preference customization
/// Tab navigation with Profile tab active
class UserProfileSettings extends StatefulWidget {
  const UserProfileSettings({super.key});

  @override
  State<UserProfileSettings> createState() => _UserProfileSettingsState();
}

class _UserProfileSettingsState extends State<UserProfileSettings> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "María González",
    "email": "maria.gonzalez@example.com",
    "phone": "+57 300 123 4567",
    "role": "Citizen",
    "avatar":
        "https://img.rocket.new/generatedImages/rocket_gen_img_1e20f0ace-1763299053725.png",
    "semanticLabel":
        "Profile photo of a woman with long dark hair wearing a blue shirt",
    "reputationScore": 4.7,
    "totalReports": 23,
    "verifiedPhone": true,
    "verifiedEmail": true,
    "verifiedDocuments": false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Custom AppBar content
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
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // Profile Header
                ProfileHeaderWidget(userData: userData),

                SizedBox(height: 2.h),

                // Account Section
                AccountSectionWidget(userData: userData),

                SizedBox(height: 2.h),

                // Privacy Controls
                PrivacySectionWidget(),

                SizedBox(height: 2.h),

                // Notification Preferences
                NotificationSectionWidget(),

                SizedBox(height: 2.h),

                // Safety Settings
                SafetySectionWidget(),

                SizedBox(height: 2.h),

                // Language Selection
                LanguageSectionWidget(),

                SizedBox(height: 2.h),

                // Accessibility Options
                AccessibilitySectionWidget(),

                SizedBox(height: 2.h),

                // App Preferences
                AppPreferencesWidget(),

                SizedBox(height: 2.h),

                // Account Verification
                VerificationSectionWidget(userData: userData),

                SizedBox(height: 2.h),

                // Data Export
                DataExportWidget(),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
