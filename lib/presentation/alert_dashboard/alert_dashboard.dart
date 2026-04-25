import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_routes.dart';
import '../../services/power_button_detector_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './alert_dashboard_initial_page.dart';

class AlertDashboard extends StatefulWidget {
  const AlertDashboard({super.key});

  @override
  AlertDashboardState createState() => AlertDashboardState();
}

class AlertDashboardState extends State<AlertDashboard> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;
  PowerButtonDetectorService? _powerDetector;

  // ALL CustomBottomBar routes in EXACT order matching CustomBottomBar items
  // Dashboard, Map, Report, Chat, Profile
  final List<String> routes = [
    '/alert-dashboard',
    '/interactive-safety-map',
    '/incident-reporting',
    '/community-safety-chat',
    '/user-profile-settings',
  ];

  @override
  void initState() {
    super.initState();
    _loadAndStartDetector();
  }

  Future<void> _loadAndStartDetector() async {
    final prefs = await SharedPreferences.getInstance();
    final requiredTaps = prefs.getInt('power_button_required_taps') ?? 3;
    _powerDetector = PowerButtonDetectorService(
      requiredTaps: requiredTaps,
      onTrigger: _activatePanicMode,
    );
    _powerDetector!.start();
  }

  @override
  void dispose() {
    _powerDetector?.dispose();
    super.dispose();
  }

  void switchTab(int index) {
    if (index < 0 || index >= routes.length) return;
    if (!AppRoutes.routes.containsKey(routes[index])) return;
    if (currentIndex == index) return;
    setState(() => currentIndex = index);
    navigatorKey.currentState?.pushReplacementNamed(routes[index]);
  }

  void updatePanicTaps(int taps) {
    _powerDetector?.dispose();
    _powerDetector = PowerButtonDetectorService(
      requiredTaps: taps,
      onTrigger: _activatePanicMode,
    );
    _powerDetector!.start();
  }

  void _activatePanicMode() {
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    Navigator.of(context, rootNavigator: true).pushNamed(
      AppRoutes.emergencyPanicMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        initialRoute: '/alert-dashboard',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/alert-dashboard' || '/':
              return MaterialPageRoute(
                builder: (context) => const AlertDashboardInitialPage(),
                settings: settings,
              );
            default:
              // Check AppRoutes.routes for all other routes
              if (AppRoutes.routes.containsKey(settings.name)) {
                return MaterialPageRoute(
                  builder: AppRoutes.routes[settings.name]!,
                  settings: settings,
                );
              }
              return null;
          }
        },
      ),
      // El mapa maneja su propio bottom nav (el platform view de GoogleMap
      // puede cubrir el bottom nav del Scaffold exterior en algunos dispositivos Android).
      bottomNavigationBar: currentIndex == 1
          ? null
          : CustomBottomBar(
              currentIndex: currentIndex,
              onTap: switchTab,
            ),
    );
  }
}
