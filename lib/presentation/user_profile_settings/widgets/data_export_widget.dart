import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Data Export Widget
/// Personal information download complying with Colombian privacy regulations
class DataExportWidget extends StatelessWidget {
  const DataExportWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exportar Datos Personales',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Cumple con la Ley 1581 de 2012 de Protección de Datos Personales',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Export Options
          _buildExportOption(
            context: context,
            icon: 'description',
            label: 'Exportar Información de Perfil',
            subtitle: 'Datos personales y configuración',
            onTap: () {
              _showExportDialog(context, 'Información de Perfil');
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildExportOption(
            context: context,
            icon: 'report',
            label: 'Exportar Historial de Reportes',
            subtitle: 'Todos los incidentes reportados',
            onTap: () {
              _showExportDialog(context, 'Historial de Reportes');
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildExportOption(
            context: context,
            icon: 'chat',
            label: 'Exportar Conversaciones',
            subtitle: 'Historial de chat de seguridad',
            onTap: () {
              _showExportDialog(context, 'Conversaciones');
            },
          ),

          Divider(height: 1, thickness: 1, indent: 16.w),

          _buildExportOption(
            context: context,
            icon: 'folder_zip',
            label: 'Exportar Todos los Datos',
            subtitle: 'Paquete completo de información',
            onTap: () {
              _showExportDialog(context, 'Todos los Datos');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required String icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'download',
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String dataType) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exportar $dataType'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona el formato de exportación:',
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            _buildFormatOption(context, 'PDF', 'Documento portable'),
            SizedBox(height: 1.h),
            _buildFormatOption(context, 'JSON', 'Formato estructurado'),
            SizedBox(height: 1.h),
            _buildFormatOption(context, 'CSV', 'Hoja de cálculo'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(
    BuildContext context,
    String format,
    String description,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exportando datos en formato $format...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: 'insert_drive_file',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
