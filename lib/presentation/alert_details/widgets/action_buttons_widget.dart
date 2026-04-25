import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ActionButtonsWidget extends StatelessWidget {
  final Map<String, dynamic> alertData;
  final bool isAuthority;

  const ActionButtonsWidget({
    super.key,
    required this.alertData,
    this.isAuthority = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => _getDirections(context),
            icon: CustomIconWidget(
              iconName: 'directions',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
            label: const Text('Obtener Ruta para Evitar la Zona'),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 6.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _shareAlert(context),
                  icon: CustomIconWidget(
                    iconName: 'share',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Compartir'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addUpdate(context),
                  icon: CustomIconWidget(
                    iconName: 'add_comment',
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Comentar'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 6.h),
                  ),
                ),
              ),
            ],
          ),
          if (isAuthority) ...[
            SizedBox(height: 1.h),
            ElevatedButton.icon(
              onPressed: () => _markResolved(context),
              icon: CustomIconWidget(
                iconName: 'check_circle',
                color: theme.colorScheme.onPrimary,
                size: 20,
              ),
              label: const Text('Marcar como Resuelto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: Size(double.infinity, 6.h),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _getDirections(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegación de ruta segura disponible próximamente'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical': return 'CRÍTICO 🔴';
      case 'high':     return 'ALTO 🟠';
      case 'medium':   return 'MEDIO 🟡';
      default:         return 'BAJO 🟢';
    }
  }

  void _shareAlert(BuildContext context) {
    final type = alertData['type'] as String? ?? 'Incidente';
    final severity = alertData['severity'] as String? ?? 'medium';
    final location = alertData['location'] as String? ?? 'ubicación desconocida';
    SharePlus.instance.share(
      ShareParams(
        text: '🦇 BatFinder — Alerta de Seguridad\n\n'
            '🚨 Tipo: $type\n'
            '⚡ Nivel: ${_severityLabel(severity)}\n'
            '📍 Ubicación: $location\n\n'
            '⚠️ Comparte esta alerta para mantener a tu comunidad informada y segura.',
        subject: 'Alerta de Seguridad — BatFinder',
      ),
    );
  }

  void _addUpdate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agregar Comentario',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 2.h),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Comparte información adicional sobre este incidente...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comentario publicado exitosamente'),
                          ),
                        );
                      },
                      child: const Text('Publicar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markResolved(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marcar como Resuelto'),
        content: const Text(
          '¿Estás seguro de que deseas marcar este incidente como resuelto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Incidente marcado como resuelto'),
                ),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
