import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Biometric Enrollment Widget
/// Dialog for enrolling biometric authentication
class BiometricEnrollmentWidget extends StatelessWidget {
  final VoidCallback onEnroll;
  final VoidCallback onSkip;

  const BiometricEnrollmentWidget({
    super.key,
    required this.onEnroll,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fingerprint Icon
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'fingerprint',
                color: theme.colorScheme.primary,
                size: 64,
              ),
            ),
            SizedBox(height: 3.h),

            // Title
            Text(
              'Enable Biometric Login',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),

            // Description
            Text(
              'Use your fingerprint or face to quickly and securely access your account',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),

            // Benefits
            _buildBenefit(
              context: context,
              icon: 'speed',
              text: 'Faster login experience',
            ),
            SizedBox(height: 1.h),
            _buildBenefit(
              context: context,
              icon: 'security',
              text: 'Enhanced security',
            ),
            SizedBox(height: 1.h),
            _buildBenefit(
              context: context,
              icon: 'lock',
              text: 'No need to remember passwords',
            ),
            SizedBox(height: 3.h),

            // Enroll Button
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onEnroll();
                },
                child: Text('Enable Biometric'),
              ),
            ),
            SizedBox(height: 1.h),

            // Skip Button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                onSkip();
              },
              child: Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit({
    required BuildContext context,
    required String icon,
    required String text,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
