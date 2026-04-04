import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Third onboarding page - Community safety and permissions
class OnboardingPageThreeWidget extends StatefulWidget {
  const OnboardingPageThreeWidget({super.key});

  @override
  State<OnboardingPageThreeWidget> createState() =>
      _OnboardingPageThreeWidgetState();
}

class _OnboardingPageThreeWidgetState extends State<OnboardingPageThreeWidget> {
  final Map<String, bool> _permissions = {
    'location': false,
    'camera': false,
    'notifications': false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final locationStatus = await Permission.location.status;
    final cameraStatus = await Permission.camera.status;
    final notificationStatus = await Permission.notification.status;

    setState(() {
      _permissions['location'] = locationStatus.isGranted;
      _permissions['camera'] = cameraStatus.isGranted;
      _permissions['notifications'] = notificationStatus.isGranted;
    });
  }

  Future<void> _requestPermission(String permissionType) async {
    HapticFeedback.lightImpact();

    Permission permission;
    switch (permissionType) {
      case 'location':
        permission = Permission.location;
        break;
      case 'camera':
        permission = Permission.camera;
        break;
      case 'notifications':
        permission = Permission.notification;
        break;
      default:
        return;
    }

    final status = await permission.request();
    setState(() {
      _permissions[permissionType] = status.isGranted;
    });

    if (status.isPermanentlyDenied) {
      _showSettingsDialog(permissionType);
    }
  }

  void _showSettingsDialog(String permissionType) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso Requerido', style: theme.textTheme.titleLarge),
        content: Text(
          'Por favor habilita el permiso de ${_getPermissionName(permissionType)} en la configuración de la aplicación.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Abrir Configuración'),
          ),
        ],
      ),
    );
  }

  String _getPermissionName(String type) {
    switch (type) {
      case 'location':
        return 'ubicación';
      case 'camera':
        return 'cámara';
      case 'notifications':
        return 'notificaciones';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Community illustration
          Container(
            height: 30.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomImageWidget(
                  imageUrl:
                      "https://images.unsplash.com/photo-1529156069898-49953e39b3ac?w=800&q=80",
                  width: double.infinity,
                  height: 30.h,
                  fit: BoxFit.cover,
                  semanticLabel:
                      "Grupo diverso de personas colombianas colaborando en comunidad, mostrando unidad y seguridad ciudadana",
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'groups',
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Seguridad Comunitaria',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Title
          Text(
            'Seguridad Comunitaria',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Description
          Text(
            'Únete a tu comunidad para crear un entorno más seguro. Reporta incidentes y recibe alertas de las autoridades',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Community features
          _buildCommunityFeature(
            theme,
            'Reportes Ciudadanos',
            'Documenta incidentes con fotos y ubicación',
            'photo_camera',
            theme.colorScheme.primary,
          ),

          SizedBox(height: 2.h),

          _buildCommunityFeature(
            theme,
            'Respuesta de Autoridades',
            'Recibe actualizaciones de policía y emergencias',
            'shield',
            theme.colorScheme.secondary,
          ),

          SizedBox(height: 2.h),

          _buildCommunityFeature(
            theme,
            'Integración 123',
            'Conexión directa con servicios de emergencia',
            'phone_in_talk',
            theme.colorScheme.error,
          ),

          SizedBox(height: 4.h),

          // Permissions section
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permisos Necesarios',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildPermissionItem(
                  theme,
                  'Ubicación',
                  'Monitoreo de seguridad en segundo plano',
                  'location_on',
                  'location',
                ),
                Divider(height: 3.h),
                _buildPermissionItem(
                  theme,
                  'Cámara',
                  'Documentación de incidentes',
                  'photo_camera',
                  'camera',
                ),
                Divider(height: 3.h),
                _buildPermissionItem(
                  theme,
                  'Notificaciones',
                  'Alertas de proximidad',
                  'notifications',
                  'notifications',
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildCommunityFeature(
    ThemeData theme,
    String title,
    String description,
    String icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(iconName: icon, color: color, size: 24),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
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
    );
  }

  Widget _buildPermissionItem(
    ThemeData theme,
    String title,
    String description,
    String icon,
    String permissionType,
  ) {
    final isGranted = _permissions[permissionType] ?? false;

    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: isGranted
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: isGranted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
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
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
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
        SizedBox(width: 2.w),
        isGranted
            ? Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Permitido',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : TextButton(
                onPressed: () => _requestPermission(permissionType),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                ),
                child: Text(
                  'Permitir',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ],
    );
  }
}
