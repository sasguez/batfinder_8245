import 'package:flutter/material.dart';

import '../../routes/app_routes.dart';
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
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // For the routes that are not in the AppRoutes.routes, do not navigate to them.
          if (!AppRoutes.routes.containsKey(routes[index])) {
            return;
          }
          if (currentIndex != index) {
            setState(() => currentIndex = index);
            navigatorKey.currentState?.pushReplacementNamed(routes[index]);
          }
        },
      ),
    );
  }
}
