import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const AlertCardWidget({
    super.key,
    required this.alertData,
    required this.onTap,
    required this.onShare,
  });

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    return 'hace ${diff.inDays}d';
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical': return 'CRÍTICO';
      case 'high':     return 'ALTO';
      case 'medium':   return 'MEDIO';
      default:         return 'BAJO';
    }
  }

  String _severityLabelWithEmoji(String severity) {
    switch (severity) {
      case 'critical': return 'CRÍTICO 🔴';
      case 'high':     return 'ALTO 🟠';
      case 'medium':   return 'MEDIO 🟡';
      default:         return 'BAJO 🟢';
    }
  }

  void _share() {
    final type = alertData['type'] as String? ?? 'Incidente';
    final severity = alertData['severity'] as String? ?? 'medium';
    final location = alertData['location'] as String? ?? 'ubicación desconocida';
    SharePlus.instance.share(
      ShareParams(
        text: '🦇 BatFinder — Alerta de Seguridad\n\n'
            '🚨 Tipo: $type\n'
            '⚡ Nivel: ${_severityLabelWithEmoji(severity)}\n'
            '📍 Ubicación: $location\n\n'
            '⚠️ Comparte esta alerta para mantener a tu comunidad informada y segura.',
        subject: 'Alerta de Seguridad — BatFinder',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Slidable(
        key: ValueKey(alertData["id"]),
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.46,
          children: [
            SlidableAction(
              onPressed: (context) => onTap(),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: Icons.open_in_new_rounded,
              label: 'Detalles',
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            SlidableAction(
              onPressed: (context) => _share(),
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: theme.colorScheme.onTertiary,
              icon: Icons.share_rounded,
              label: 'Compartir',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(12),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (alertData["severityColor"] as Color).withValues(
                    alpha: 0.3,
                  ),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Alert icon
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (alertData["severityColor"] as Color)
                                .withValues(alpha: 0.4),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                (alertData["severityColor"] as Color),
                                (alertData["severityColor"] as Color)
                                    .withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (alertData["severityColor"] as Color)
                                    .withValues(alpha: 0.5),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: alertData["icon"] as String,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Alert type and timestamp
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alertData["type"] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  _formatTimestamp(
                                    alertData["timestamp"] as DateTime,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  alertData["distance"] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Severity indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: (alertData["severityColor"] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _severityLabel(alertData["severity"] as String? ?? 'medium'),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: alertData["severityColor"] as Color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Alert description
                  Text(
                    alertData["description"] as String,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // Alert location
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'place',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          alertData["location"] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
