import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleLogin;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Colors.white24, thickness: 1)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'O continúa con',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
              ),
            ),
            Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          ],
        ),
        SizedBox(height: 3.h),
        SizedBox(
          width: double.infinity,
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
              'Continuar con Google',
              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.8.h),
              side: const BorderSide(color: Colors.white30, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
