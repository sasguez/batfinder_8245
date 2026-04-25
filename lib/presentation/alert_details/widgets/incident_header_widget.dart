import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class IncidentHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;

  const IncidentHeaderWidget({super.key, required this.alertData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String incidentType = alertData['type'] as String? ?? 'Incidente';
    final DateTime timestamp =
        alertData['timestamp'] as DateTime? ?? DateTime.now();
    final String location =
        alertData['location'] as String? ?? 'Ubicación no disponible';
    final String severity =
        alertData['severity'] as String? ?? 'medium';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getIncidentColor(incidentType, theme),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  incidentType.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: _getSeverityColor(severity, theme).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _severityLabel(severity),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getSeverityColor(severity, theme),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'access_time',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                _formatTimestamp(timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'location_on',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  location,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getIncidentColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'robo':        return theme.colorScheme.error;
      case 'violencia':   return theme.colorScheme.primary;
      case 'emergencia':  return theme.colorScheme.error;
      default:            return theme.colorScheme.secondary;
    }
  }

  Color _getSeverityColor(String severity, ThemeData theme) {
    switch (severity) {
      case 'critical': return const Color(0xFFB71C1C);
      case 'high':     return const Color(0xFFD32F2F);
      case 'medium':   return const Color(0xFFF57C00);
      default:         return const Color(0xFF2E7D32);
    }
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical': return 'CRÍTICO';
      case 'high':     return 'ALTO';
      case 'medium':   return 'MEDIO';
      default:         return 'BAJO';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }
}
