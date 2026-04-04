import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Social login buttons widget for Google and Facebook authentication
class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleLogin;
  final VoidCallback onFacebookLogin;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleLogin,
    required this.onFacebookLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(color: theme.colorScheme.outline, thickness: 1),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'O continúa con',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: theme.colorScheme.outline, thickness: 1),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Social login buttons
        Row(
          children: [
            // Google login button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onGoogleLogin();
                },
                icon: CustomImageWidget(
                  imageUrl: 'https://www.google.com/favicon.ico',
                  width: 5.w,
                  height: 5.w,
                  fit: BoxFit.contain,
                  semanticLabel: 'Logo de Google con letra G multicolor',
                ),
                label: Text(
                  'Google',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  side: BorderSide(color: theme.colorScheme.outline, width: 1),
                ),
              ),
            ),
            SizedBox(width: 4.w),

            // Facebook login button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onFacebookLogin();
                },
                icon: CustomImageWidget(
                  imageUrl: 'https://www.facebook.com/favicon.ico',
                  width: 5.w,
                  height: 5.w,
                  fit: BoxFit.contain,
                  semanticLabel:
                      'Logo de Facebook con letra f blanca sobre fondo azul',
                ),
                label: Text(
                  'Facebook',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 1.8.h),
                  side: BorderSide(color: theme.colorScheme.outline, width: 1),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
