import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Second onboarding page - Emergency features
class OnboardingPageTwoWidget extends StatefulWidget {
  const OnboardingPageTwoWidget({super.key});

  @override
  State<OnboardingPageTwoWidget> createState() =>
      _OnboardingPageTwoWidgetState();
}

class _OnboardingPageTwoWidgetState extends State<OnboardingPageTwoWidget> {
  bool _isPanicPressed = false;
  bool _isShakeDetected = false;

  void _simulatePanicPress() {
    setState(() {
      _isPanicPressed = true;
    });
    HapticFeedback.heavyImpact();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isPanicPressed = false;
        });
      }
    });
  }

  void _simulateShake() {
    setState(() {
      _isShakeDetected = true;
    });
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isShakeDetected = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        children: [
          SizedBox(height: 2.h),

          // Emergency illustration
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
                // Background
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.1),
                        theme.colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),

                // Panic button visualization
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: _isPanicPressed ? 35.w : 30.w,
                      height: _isPanicPressed ? 35.w : 30.w,
                      decoration: BoxDecoration(
                        color: _isPanicPressed
                            ? theme.colorScheme.error
                            : theme.colorScheme.error.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        boxShadow: _isPanicPressed
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'emergency',
                          color: Colors.white,
                          size: _isPanicPressed ? 48 : 40,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    if (_isPanicPressed)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Compartiendo ubicación...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
            'Funciones de Emergencia',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          // Description
          Text(
            'Accede rápidamente a ayuda de emergencia con un solo toque o gesto',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Interactive features
          _buildFeatureCard(
            theme,
            'Botón de Pánico',
            'Presiona para activar alerta de emergencia',
            'emergency',
            theme.colorScheme.error,
            _simulatePanicPress,
            _isPanicPressed,
          ),

          SizedBox(height: 2.h),

          _buildFeatureCard(
            theme,
            'Activación por Volumen',
            'Presiona 3 veces el botón de volumen',
            'volume_up',
            theme.colorScheme.primary,
            null,
            false,
          ),

          SizedBox(height: 2.h),

          _buildFeatureCard(
            theme,
            'Agitar para Alertar',
            'Agita tu dispositivo para activar',
            'vibration',
            theme.colorScheme.secondary,
            _simulateShake,
            _isShakeDetected,
          ),

          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    ThemeData theme,
    String title,
    String description,
    String icon,
    Color color,
    VoidCallback? onTap,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? color
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
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
            if (onTap != null)
              CustomIconWidget(
                iconName: 'touch_app',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
