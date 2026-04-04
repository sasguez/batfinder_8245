import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/realtime_dashboard_service.dart';
import './widgets/community_engagement_widget.dart';
import './widgets/geographic_hotspots_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/predictive_hotspot_map_widget.dart';
import './widgets/resolution_rate_widget.dart';
import './widgets/response_benchmark_widget.dart';
import './widgets/response_time_chart_widget.dart';

class RealtimeDashboardScreen extends StatefulWidget {
  const RealtimeDashboardScreen({super.key});

  @override
  State<RealtimeDashboardScreen> createState() =>
      _RealtimeDashboardScreenState();
}

class _RealtimeDashboardScreenState extends State<RealtimeDashboardScreen> {
  final RealtimeDashboardService _dashboardService = RealtimeDashboardService();
  DashboardStatistics? _currentStats;
  List<GeographicHotspot> _hotspots = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  Future<void> _initializeDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _dashboardService.subscribeToStatistics();
      _dashboardService.subscribeToIncidents();

      _dashboardService.statisticsStream.listen((stats) {
        if (mounted) {
          setState(() {
            _currentStats = stats;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      });

      _dashboardService.hotspotsStream.listen((hotspots) {
        if (mounted) {
          setState(() {
            _hotspots = hotspots;
          });
        }
      });

      final initialStats = await _dashboardService.fetchTodayStatistics();
      final initialHotspots = await _dashboardService.fetchGeographicHotspots();

      if (mounted) {
        setState(() {
          _currentStats = initialStats;
          _hotspots = initialHotspots;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar datos: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _dashboardService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Dashboard en Tiempo Real',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A73E8),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshDashboard,
          ),
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: Colors.white, size: 8.sp),
                SizedBox(width: 1.w),
                Text(
                  'En Vivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : _currentStats == null ||
                (_currentStats!.totalIncidents == 0 && _hotspots.isEmpty)
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _refreshDashboard,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Métricas de Incidentes',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildMetricsGrid(),
                    SizedBox(height: 3.h),
                    Text(
                      'Tiempo de Respuesta',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: ResponseTimeChartWidget(
                            averageResponseTime:
                                _currentStats?.averageResponseTime ?? 0,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ResolutionRateWidget(
                            resolutionRate:
                                _currentStats?.resolutionRate ?? 0.0,
                            totalIncidents: _currentStats?.totalIncidents ?? 0,
                            resolvedIncidents:
                                _currentStats?.resolvedIncidents ?? 0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Puntos Críticos Geográficos',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    GeographicHotspotsWidget(hotspots: _hotspots),
                    SizedBox(height: 3.h),
                    PredictiveHotspotMapWidget(),
                    SizedBox(height: 3.h),
                    ResponseBenchmarkWidget(),
                    SizedBox(height: 3.h),
                    CommunityEngagementWidget(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 3.h),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Los reportes aparecerán aquí cuando se registren nuevos incidentes',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80.sp, color: Colors.red.shade400),
            SizedBox(height: 3.h),
            Text(
              'Error al cargar datos',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage ?? 'Ocurrió un error inesperado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: _refreshDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2.h,
      crossAxisSpacing: 3.w,
      childAspectRatio: 1.5,
      children: [
        MetricCardWidget(
          title: 'Alertas Recibidas',
          value: _currentStats?.totalIncidents.toString() ?? '0',
          icon: Icons.report_problem,
          color: const Color(0xFF1A73E8),
          trend: _getTrend('total'),
        ),
        MetricCardWidget(
          title: 'Pendientes',
          value: _currentStats?.pendingIncidents.toString() ?? '0',
          icon: Icons.pending,
          color: const Color(0xFFFFA726),
          trend: _getTrend('pending'),
        ),
        MetricCardWidget(
          title: 'Resueltas',
          value: _currentStats?.resolvedIncidents.toString() ?? '0',
          icon: Icons.check_circle,
          color: const Color(0xFF66BB6A),
          trend: _getTrend('resolved'),
        ),
        MetricCardWidget(
          title: 'Verificadas',
          value: _currentStats?.verifiedIncidents.toString() ?? '0',
          icon: Icons.verified,
          color: const Color(0xFF26A69A),
          trend: _getTrend('verified'),
        ),
      ],
    );
  }

  String _getTrend(String type) {
    return '+0%';
  }

  Future<void> _refreshDashboard() async {
    setState(() => _isLoading = true);
    await _initializeDashboard();
  }
}
