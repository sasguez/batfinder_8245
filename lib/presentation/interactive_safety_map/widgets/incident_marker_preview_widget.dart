import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Incident Marker Preview Widget
/// Shows detailed information about a selected incident marker
class IncidentMarkerPreviewWidget extends StatelessWidget {
  final Map<String, dynamic> incident;
  final ScrollController scrollController;
  final VoidCallback onClose;

  const IncidentMarkerPreviewWidget({
    super.key,
    required this.incident,
    required this.scrollController,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Detalles del Incidente',
                style: theme.textTheme.titleLarge,
              ),
            ),
            IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: onClose,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _getSeverityColor(
              incident["severity"] as String,
            ).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getSeverityColor(incident["severity"] as String),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getSeverityColor(incident["severity"] as String),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                _getSeverityLabel(incident["severity"] as String),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _getSeverityColor(incident["severity"] as String),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          incident["title"] as String,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'category',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(incident["type"] as String, style: theme.textTheme.bodyMedium),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'access_time',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              _formatTimestamp(incident["timestamp"] as DateTime),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Divider(),
        SizedBox(height: 2.h),
        Text(
          'Descripción',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          incident["description"] as String,
          style: theme.textTheme.bodyMedium,
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'person',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Reportado por: ${incident["reporter"]}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: incident["verified"] == true ? 'verified' : 'pending',
              color: incident["verified"] == true
                  ? Colors.green
                  : Colors.orange,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              incident["verified"] == true
                  ? 'Verificado'
                  : 'Pendiente de verificación',
              style: theme.textTheme.bodySmall?.copyWith(
                color: incident["verified"] == true
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Lat: ${(incident["location"]["lat"] as num).toStringAsFixed(4)}, Lng: ${(incident["location"]["lng"] as num).toStringAsFixed(4)}',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pushNamed('/alert-details');
          },
          icon: CustomIconWidget(
            iconName: 'info',
            color: theme.colorScheme.onPrimary,
            size: 20,
          ),
          label: Text('Ver Detalles Completos'),
        ),
        SizedBox(height: 1.h),
        OutlinedButton.icon(
          onPressed: () {},
          icon: CustomIconWidget(
            iconName: 'directions',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          label: Text('Obtener Direcciones'),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "critical":
        return Colors.red;
      case "high":
        return Colors.orange;
      case "medium":
        return Colors.yellow;
      case "low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity) {
      case "critical":
        return 'CRÍTICO';
      case "high":
        return 'ALTO';
      case "medium":
        return 'MEDIO';
      case "low":
        return 'BAJO';
      default:
        return 'DESCONOCIDO';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} horas';
    } else {
      return 'Hace ${difference.inDays} días';
    }
  }
}
