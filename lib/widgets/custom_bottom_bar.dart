import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom bottom navigation bar for Colombian Safety App
/// Implements bottom-heavy interaction design with thumb-accessible primary functions
/// Matches Mobile Navigation Hierarchy: Dashboard, Map, Report, Chat, Profile
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // Haptic feedback for tab switching (light impact)
          HapticFeedback.lightImpact();
          onTap(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor,
        selectedLabelStyle: theme.bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle:
            theme.bottomNavigationBarTheme.unselectedLabelStyle,
        elevation: 8.0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          // Dashboard/Home - Alert Dashboard (Central safety hub)
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined, size: 24),
            activeIcon: Icon(Icons.dashboard, size: 24),
            label: 'Dashboard',
            tooltip: 'Alert Dashboard - View safety alerts',
          ),
          // Map/Location - Interactive Safety Map (Spatial context)
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined, size: 24),
            activeIcon: Icon(Icons.map, size: 24),
            label: 'Map',
            tooltip: 'Safety Map - View location-based alerts',
          ),
          // Report/Plus - Incident Reporting (Quick incident documentation)
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, size: 24),
            activeIcon: Icon(Icons.add_circle, size: 24),
            label: 'Report',
            tooltip: 'Report Incident - Document safety concerns',
          ),
          // Chat/Messages - Community Safety Chat (Communication hub)
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline, size: 24),
            activeIcon: Icon(Icons.chat_bubble, size: 24),
            label: 'Chat',
            tooltip: 'Safety Chat - Community communication',
          ),
          // Profile/Settings - User Profile Settings (Account management)
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 24),
            activeIcon: Icon(Icons.person, size: 24),
            label: 'Profile',
            tooltip: 'Profile - Account and safety preferences',
          ),
        ],
      ),
    );
  }
}
