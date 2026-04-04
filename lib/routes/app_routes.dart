import 'package:flutter/material.dart';

import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/user_registration/user_registration.dart';
import '../presentation/alert_dashboard/alert_dashboard.dart';
import '../presentation/alert_details/alert_details.dart';
import '../presentation/incident_reporting/incident_reporting.dart';
import '../presentation/create_edit_incident_screen/create_edit_incident_screen.dart';
import '../presentation/emergency_panic_mode/emergency_panic_mode.dart';
import '../presentation/interactive_safety_map/interactive_safety_map.dart';
import '../presentation/user_profile_settings/user_profile_settings.dart';
import '../presentation/community_safety_chat/community_safety_chat.dart';
import '../presentation/realtime_dashboard/realtime_dashboard_screen.dart';
import '../presentation/enhanced_map_screen/enhanced_map_screen.dart';
import '../presentation/profile_edit_screen/profile_edit_screen.dart';
import '../presentation/incident_reporting/widgets/offline_queue_widget.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String registration = '/registration';
  static const String alertDashboard = '/alert-dashboard';
  static const String alertDetails = '/alert-details';
  static const String incidentReporting = '/incident-reporting';
  static const String createEditIncident = '/create-edit-incident';
  static const String emergencyPanicMode = '/emergency-panic-mode';
  static const String interactiveSafetyMap = '/interactive-safety-map';
  static const String userProfileSettings = '/user-profile-settings';
  static const String communitySafetyChat = '/community-safety-chat';
  static const String realtimeDashboard = '/realtime-dashboard';
  static const String enhancedMapScreen = '/enhanced-map';
  static const String profileEditScreen = '/profile-edit';
  static const String offlineQueue = '/offline-queue';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingFlow(),
      login: (context) => const LoginScreen(),
      registration: (context) => const UserRegistration(),
      alertDashboard: (context) => const AlertDashboard(),
      alertDetails: (context) => const AlertDetails(),
      incidentReporting: (context) => const IncidentReporting(),
      createEditIncident: (context) => const CreateEditIncidentScreen(),
      emergencyPanicMode: (context) => const EmergencyPanicMode(),
      interactiveSafetyMap: (context) => const InteractiveSafetyMap(),
      userProfileSettings: (context) => const UserProfileSettings(),
      communitySafetyChat: (context) => const CommunitySafetyChat(),
      realtimeDashboard: (context) => const RealtimeDashboardScreen(),
      enhancedMapScreen: (context) => const EnhancedMapScreen(),
      profileEditScreen: (context) => const ProfileEditScreen(),
      offlineQueue: (context) => const OfflineQueueWidget(),
    };
  }
}