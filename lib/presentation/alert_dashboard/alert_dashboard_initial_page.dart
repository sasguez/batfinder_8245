import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
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

class _AlertDashboardInitialPageState
    extends State<AlertDashboardInitialPage> {
  bool _isLoading = true;
  // ignore: prefer_final_fields — will be updated with real GPS location
  String _currentLocation = 'Colombia';
  DateTime _lastUpdated = DateTime.now();

  List<Map<String, dynamic>> _incidents = [];
  Map<String, dynamic> _stats = {};
  int _safetyScore = 85;

  RealtimeChannel? _realtimeChannel;
  final _dio = Dio();

  static const Map<String, String> _typeLabels = {
    'theft': 'Robo',
    'assault': 'Violencia',
    'suspicious': 'Actividad Sospechosa',
    'emergency': 'Emergencia',
    'vandalism': 'Vandalismo',
    'other': 'Otro',
  };

  static const Map<String, String> _typeIcons = {
    'theft': 'local_police',
    'assault': 'warning',
    'suspicious': 'visibility',
    'emergency': 'emergency',
    'vandalism': 'broken_image',
    'other': 'report_problem',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
    _subscribeToRealtime();
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _dio.close();
    super.dispose();
  }

  bool _looksLikeCoordinates(String s) =>
      RegExp(r'^-?\d+\.?\d*,\s*-?\d+\.?\d*$').hasMatch(s.trim());

  Future<String?> _reverseGeocode(double lat, double lng) async {
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (apiKey.isNotEmpty) {
      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '$lat,$lng',
            'key': apiKey,
            'language': 'es',
          },
        );
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results[0]['formatted_address'] as String?;
        }
      } catch (_) {}
    }
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': '$lat',
          'lon': '$lng',
          'format': 'json',
          'accept-language': 'es',
        },
        options: Options(headers: {'User-Agent': 'BatFinder/1.0'}),
      );
      final address = response.data['address'] as Map<String, dynamic>?;
      if (address != null) {
        final neighbourhood = address['neighbourhood'] as String?
            ?? address['suburb'] as String?;
        final city = address['city'] as String?
            ?? address['town'] as String?
            ?? address['village'] as String?;
        final state = address['state'] as String?;
        final parts = [neighbourhood, city, state]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return null;
  }

  Future<void> _geocodeIncidents() async {
    for (int i = 0; i < _incidents.length; i++) {
      final location = _incidents[i]['location'] as String? ?? '';
      if (!_looksLikeCoordinates(location)) continue;
      final lat = (_incidents[i]['latitude'] as num?)?.toDouble();
      final lng = (_incidents[i]['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final geocoded = await _reverseGeocode(lat, lng);
      if (geocoded != null && mounted) {
        setState(() {
          _incidents[i] = Map<String, dynamic>.from(_incidents[i])
            ..['location'] = geocoded;
        });
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFB71C1C);
      case 'high':
        return const Color(0xFFD32F2F);
      case 'low':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFF57C00);
    }
  }

  Map<String, dynamic> _mapIncident(Map<String, dynamic> raw) {
    final type = raw['incident_type'] as String? ?? 'other';
    final severity = raw['severity'] as String? ?? 'medium';
    final createdAt = raw['created_at'] as String?;
    return {
      'id': raw['id'],
      'type': _typeLabels[type] ?? 'Incidente',
      'icon': _typeIcons[type] ?? 'report_problem',
      'timestamp':
          createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
      'distance': 'N/A',
      'severity': severity,
      'severityColor': _getSeverityColor(severity),
      'description': raw['description'] ?? 'Sin descripción',
      'location': raw['location_address'] ?? 'Ubicación no especificada',
      'latitude': raw['latitude'],
      'longitude': raw['longitude'],
      'incident_type': type,
      'status': raw['status'] ?? 'active',
    };
  }

  int _calcSafetyScore(Map<String, dynamic> stats) {
    final total = (stats['total_alerts'] as num?)?.toInt() ?? 0;
    final active = (stats['active_alerts'] as num?)?.toInt() ?? 0;
    if (total == 0) return 85;
    final activeRate = active / total;
    return (100 - (activeRate * 80)).round().clamp(20, 100);
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        SupabaseService.getIncidents(status: 'active', limit: 20),
        SupabaseService.getDashboardStatistics(),
      ]);

      final rawIncidents = results[0] as List<Map<String, dynamic>>;
      final stats = results[1] as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          _incidents = rawIncidents.map(_mapIncident).toList();
          _stats = stats;
          _safetyScore = _calcSafetyScore(stats);
          _lastUpdated = DateTime.now();
          _isLoading = false;
        });
        _geocodeIncidents();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _subscribeToRealtime() {
    _realtimeChannel = SupabaseService.subscribeToIncidents((raw) {
      if (mounted) {
        setState(() => _incidents.insert(0, _mapIncident(raw)));
      }
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    await _loadData();
    if (mounted) HapticFeedback.lightImpact();
  }

  void _handleEmergencyPanic() {
    HapticFeedback.heavyImpact();
    Navigator.of(context, rootNavigator: true).pushNamed(
      '/emergency-panic-mode',
    );
  }

  void _handleLocationRefresh() {
    HapticFeedback.lightImpact();
    setState(() => _lastUpdated = DateTime.now());
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
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
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: theme.colorScheme.primary,
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
                                iconName: 'wifi',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 12,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Conectado',
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
                      tooltip: 'Actualizar',
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              // SOS button
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  color: theme.colorScheme.primary,
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    children: [
                      SafetyScoreWidget(
                        score: _safetyScore,
                        location: _currentLocation,
                        stats: _stats,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('¿Cómo se calcula la puntuación?'),
                              content: const Text(
                                'La puntuación de seguridad refleja el nivel de '
                                'riesgo de tu área en tiempo real:\n\n'
                                '🟢  70 – 100 → Zona segura\n'
                                '🟡  40 – 69  → Riesgo moderado\n'
                                '🔴  0 – 39   → Zona de alto riesgo\n\n'
                                'Se calcula con base en el número de incidentes '
                                'activos vs. resueltos reportados por la comunidad. '
                                'Se actualiza automáticamente con cada nuevo reporte.',
                              ),
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16,
                                    bottom: 12,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Entendido'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 3.h),

                      // Quick actions
                      Row(
                        children: [
                          Expanded(
                            child: QuickActionWidget(
                              icon: 'add_alert',
                              label: 'Reportar Incidente',
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
                              label: 'Mapa de Seguridad',
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
                            'Alertas Recientes (24h)',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Actualizado ${_formatTimestamp(_lastUpdated)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      if (_incidents.isEmpty)
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
                                'Sin Alertas Recientes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Tu área está actualmente segura. Mantente alerta y reporta cualquier actividad sospechosa.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Consejos de Seguridad',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '• Mantente atento a tu entorno\n• Guarda tus objetos de valor\n• Usa rutas iluminadas y transitadas\n• Comparte tu ubicación con contactos de confianza',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ..._incidents.map(
                          (incident) => AlertCardWidget(
                            alertData: incident,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(
                                context,
                                rootNavigator: true,
                              ).pushNamed('/alert-details', arguments: incident);
                            },
                            onShare: () => HapticFeedback.lightImpact(),
                          ),
                        ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
