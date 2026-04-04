import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// First onboarding page - Real-time alert system
class OnboardingPageOneWidget extends StatefulWidget {
  const OnboardingPageOneWidget({super.key});

  @override
  State<OnboardingPageOneWidget> createState() =>
      _OnboardingPageOneWidgetState();
}

class _OnboardingPageOneWidgetState extends State<OnboardingPageOneWidget> {
  String? _selectedAlertType;

  final List<Map<String, dynamic>> _alertTypes = [
    {
      "type": "Robo",
      "icon": "local_police",
      "color": Color(0xFFD32F2F),
      "description": "Reportes de robos y hurtos en tiempo real",
    },
    {
      "type": "Violencia",
      "icon": "warning",
      "color": Color(0xFFF57C00),
      "description": "Alertas de situaciones violentas",
    },
    {
      "type": "Actividad Sospechosa",
      "icon": "visibility",
      "color": Color(0xFFFFD700),
      "description": "Comportamientos inusuales reportados",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Animated map illustration
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
                // Map background
                CustomImageWidget(
                  imageUrl:
                      "https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800&q=80",
                  width: double.infinity,
                  height: 30.h,
                  fit: BoxFit.cover,
                  semanticLabel:
                      "Mapa de Colombia mostrando ciudades principales con marcadores de ubicación",
                ),

                // Overlay gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.black.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),

                // Animated markers
                Positioned(
                  top: 8.h,
                  left: 15.w,
                  child: _buildAnimatedMarker(theme, Color(0xFFD32F2F)),
                ),
                Positioned(
                  top: 12.h,
                  right: 20.w,
                  child: _buildAnimatedMarker(theme, Color(0xFFF57C00)),
                ),
                Positioned(
                  bottom: 8.h,
                  left: 25.w,
                  child: _buildAnimatedMarker(theme, Color(0xFFFFD700)),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Title
          Text(
            'Sistema de Alertas en Tiempo Real',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Description
          Text(
            'Mantente informado sobre incidentes de seguridad en tu zona con alertas instantáneas de la comunidad',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Interactive alert types
          Text(
            'Toca para explorar tipos de alertas:',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 2.h),

          // Alert type cards
          ..._alertTypes.map((alert) => _buildAlertTypeCard(theme, alert)),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildAnimatedMarker(ThemeData theme, Color color) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 4.w,
          height: 4.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertTypeCard(ThemeData theme, Map<String, dynamic> alert) {
    final isSelected = _selectedAlertType == alert["type"];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAlertType = isSelected ? null : alert["type"];
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? alert["color"].withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? alert["color"]
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: alert["color"].withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: alert["icon"],
                  color: alert["color"],
                  size: 24,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert["type"],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (isSelected) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      alert["description"],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            CustomIconWidget(
              iconName: isSelected ? 'expand_less' : 'expand_more',
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
