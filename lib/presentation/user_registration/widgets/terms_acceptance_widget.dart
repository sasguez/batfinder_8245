import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Terms Acceptance Widget
/// Checkbox for accepting terms and conditions
class TermsAcceptanceWidget extends StatelessWidget {
  final bool termsAccepted;
  final Function(bool?) onChanged;

  const TermsAcceptanceWidget({
    super.key,
    required this.termsAccepted,
    required this.onChanged,
  });

  void _showTermsDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BatFinder Terms of Service',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Last Updated: January 13, 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '1. Acceptance of Terms',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'By creating an account, you agree to comply with Colombian data privacy regulations and our community safety guidelines.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '2. Data Privacy',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'We protect your personal information in accordance with Colombian Law 1581 of 2012 (Habeas Data). Your location data is encrypted and only shared with authorized authorities when necessary.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '3. User Responsibilities',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Users must provide accurate information, report incidents truthfully, and respect community guidelines. False reports may result in account suspension.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '4. Emergency Services',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'BatFinder complements but does not replace official emergency services (123). Always contact authorities directly in life-threatening situations.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Privacy Policy'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BatFinder Privacy Policy',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Last Updated: January 13, 2026',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '1. Information We Collect',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'We collect personal information (name, email, phone), location data, incident reports, and device information to provide safety services.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '2. How We Use Your Data',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Your data helps us provide real-time safety alerts, crime prevention analytics, and coordinate with authorities. We never sell your personal information.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '3. Data Sharing',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'We share data with Colombian authorities and emergency services only when necessary for public safety. NGO partners receive anonymized data for research.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 1.5.h),
              Text(
                '4. Your Rights',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'You have the right to access, correct, or delete your personal data. Contact us at privacy@batfinder.co to exercise these rights.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: termsAccepted,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              onChanged(value);
            },
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.lightImpact();
                      _showTermsDialog(context);
                    },
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.lightImpact();
                      _showPrivacyDialog(context);
                    },
                ),
                TextSpan(
                  text:
                      ', including compliance with Colombian data privacy regulations (Law 1581 of 2012)',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
