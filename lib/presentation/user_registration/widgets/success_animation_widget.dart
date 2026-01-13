import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Success Animation Widget
/// Shows success animation after registration
class SuccessAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const SuccessAnimationWidget({super.key, required this.onComplete});

  @override
  State<SuccessAnimationWidget> createState() => _SuccessAnimationWidgetState();
}

class _SuccessAnimationWidgetState extends State<SuccessAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    Future.delayed(Duration(seconds: 3), () {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: Color(0xFF2E7D32),
                  size: 80,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'Welcome to BatFinder!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Your account has been created successfully',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 4,
                    width: 60.w,
                    child: LinearProgressIndicator(
                      backgroundColor: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
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
