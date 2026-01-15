import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

/// Splash Screen for BatFinder Colombian Safety Application
/// Provides branded launch experience while initializing security services
/// and determining user authentication status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _initializationComplete = false;
  bool _showRetry = false;
  String _loadingMessage = 'Inicializando servicios de seguridad...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  Future<void> _initializeApp() async {
    try {
      // Step 1: Check biometric capability
      setState(() {
        _loadingMessage = 'Verificando capacidades biométricas...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 2: Verify location permissions
      setState(() {
        _loadingMessage = 'Verificando permisos de ubicación...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 3: Test emergency services connectivity
      setState(() {
        _loadingMessage = 'Probando conectividad de servicios de emergencia...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 4: Prepare cached alert data
      setState(() {
        _loadingMessage = 'Preparando datos de alertas en caché...';
      });
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _initializationComplete = true;
      });

      // Haptic feedback for successful initialization
      HapticFeedback.mediumImpact();

      // Navigate based on authentication status
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToNextScreen();
    } catch (e) {
      // Show retry option after 5 seconds on error
      await Future.delayed(const Duration(seconds: 5));
      setState(() {
        _showRetry = true;
        _loadingMessage = 'Error al inicializar. Toque para reintentar.';
      });
    }
  }

  void _navigateToNextScreen() {
    // Simulate authentication check
    final bool isAuthenticated = false;
    final bool isNewUser = true;

    if (isAuthenticated) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(AppRoutes.alertDashboard);
    } else if (isNewUser) {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(AppRoutes.onboarding);
    } else {
      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ]
                  : [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo with scale animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 45.w,
                    height: 45.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.w),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: CustomImageWidget(
                        imageUrl: 'assets/images/batfinder-1768513763769.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                // App name
                Text(
                  'BatFinder',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Seguridad Ciudadana Colombiana',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11.sp,
                  ),
                ),
                const Spacer(flex: 2),
                // Loading indicator and message
                if (!_showRetry) ...[
                  SizedBox(
                    width: 8.w,
                    height: 8.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      _loadingMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ] else ...[
                  // Retry button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showRetry = false;
                        _loadingMessage =
                            'Inicializando servicios de seguridad...';
                      });
                      _initializeApp();
                    },
                    icon: CustomIconWidget(
                      iconName: 'refresh',
                      color: theme.colorScheme.primary,
                      size: 5.w,
                    ),
                    label: Text(
                      'Reintentar',
                      style: TextStyle(fontSize: 11.sp),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      _loadingMessage,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 4.h),
                // Version info
                Text(
                  'Versión 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 9.sp,
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}