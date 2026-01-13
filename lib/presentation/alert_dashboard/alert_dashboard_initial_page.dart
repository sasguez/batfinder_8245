import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/alert_card_widget.dart';
import './widgets/quick_action_widget.dart';
import './widgets/safety_score_widget.dart';

class AlertDashboardInitialPage extends StatefulWidget {
  const AlertDashboardInitialPage({super.key});

  @override
  State<AlertDashboardInitialPage> createState() =>
      _AlertDashboardInitialPageState();
}

class _AlertDashboardInitialPageState extends State<AlertDashboardInitialPage> {
  bool _isRefreshing = false;
  final String _currentLocation = "Chapinero, Bogotá";
  final bool _locationServicesEnabled = true;
  final bool _networkConnected = true;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for recent alerts
  final List<Map<String, dynamic>> _recentAlerts = [
    {
      "id": 1,
      "type": "Theft",
      "icon": "local_police",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "distance": "0.3 km",
      "severity": "high",
      "severityColor": Color(0xFFD32F2F),
      "description": "Reported theft near Parque 93",
      "location": "Calle 93 #13-45",
    },
    {
      "id": 2,
      "type": "Suspicious Activity",
      "icon": "visibility",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "distance": "0.8 km",
      "severity": "medium",
      "severityColor": Color(0xFFF57C00),
      "description": "Suspicious person reported in the area",
      "location": "Carrera 15 #85-20",
    },
    {
      "id": 3,
      "type": "Violence",
      "icon": "warning",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
      "distance": "1.2 km",
      "severity": "high",
      "severityColor": Color(0xFFD32F2F),
      "description": "Physical altercation reported",
      "location": "Avenida 82 #10-30",
    },
    {
      "id": 4,
      "type": "Safe Zone",
      "icon": "check_circle",
      "timestamp": DateTime.now().subtract(Duration(hours: 5)),
      "distance": "0.5 km",
      "severity": "low",
      "severityColor": Color(0xFF2E7D32),
      "description": "Area marked as safe by community",
      "location": "Parque de la 93",
    },
  ];

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    // Simulate data refresh
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
    });

    HapticFeedback.lightImpact();
  }

  void _handleEmergencyPanic() {
    HapticFeedback.heavyImpact();
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamed('/emergency-panic-mode');
  }

  void _handleLocationRefresh() {
    HapticFeedback.lightImpact();
    setState(() {
      _lastUpdated = DateTime.now();
    });
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Custom App Bar
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 2.h,
            left: 4.w,
            right: 4.w,
            bottom: 2.h,
          ),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 4.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Location section
              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: _locationServicesEnabled
                          ? 'location_on'
                          : 'location_off',
                      color: _locationServicesEnabled
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentLocation,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: _networkConnected
                                    ? 'wifi'
                                    : 'wifi_off',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _networkConnected ? 'Connected' : 'Offline',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _handleLocationRefresh,
                      icon: CustomIconWidget(
                        iconName: 'refresh',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              // Emergency panic button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleEmergencyPanic,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'emergency',
                            color: theme.colorScheme.onError,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'SOS',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.onError,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Main content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: theme.colorScheme.primary,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              children: [
                // Safety score widget
                SafetyScoreWidget(
                  score: 72,
                  location: _currentLocation,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Show detailed breakdown
                  },
                ),

                SizedBox(height: 3.h),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: QuickActionWidget(
                        icon: 'add_alert',
                        label: 'Report Incident',
                        color: theme.colorScheme.primary,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed('/incident-reporting');
                        },
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: QuickActionWidget(
                        icon: 'map',
                        label: 'Safety Map',
                        color: theme.colorScheme.secondary,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushNamed('/interactive-safety-map');
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Recent alerts header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Alerts (24h)',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Updated ${_formatTimestamp(_lastUpdated)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Recent alerts list
                if (_recentAlerts.isEmpty)
                  Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: theme.colorScheme.primary,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No Recent Alerts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Your area is currently safe. Stay vigilant and report any suspicious activity.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Safety Tips',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          '• Always be aware of your surroundings\n• Keep valuables out of sight\n• Use well-lit and populated routes\n• Share your location with trusted contacts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ..._recentAlerts
                      .map(
                        (alert) => AlertCardWidget(
                          alertData: alert,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushNamed('/alert-details', arguments: alert);
                          },
                          onShare: () {
                            HapticFeedback.lightImpact();
                            // Share alert functionality
                          },
                        ),
                      )
                      ,

                SizedBox(height: 10.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
