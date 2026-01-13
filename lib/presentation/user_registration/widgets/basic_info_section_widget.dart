import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Basic Information Section Widget
/// Captures user's basic information including name, email, phone, and password
class BasicInfoSectionWidget extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool showPassword;
  final double passwordStrength;
  final VoidCallback onTogglePassword;

  const BasicInfoSectionWidget({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.showPassword,
    required this.passwordStrength,
    required this.onTogglePassword,
  });

  String _getPasswordStrengthText() {
    if (passwordStrength == 0.0) return 'Weak';
    if (passwordStrength <= 0.25) return 'Weak';
    if (passwordStrength <= 0.5) return 'Fair';
    if (passwordStrength <= 0.75) return 'Good';
    return 'Strong';
  }

  Color _getPasswordStrengthColor(BuildContext context) {
    final theme = Theme.of(context);
    if (passwordStrength == 0.0) return theme.colorScheme.error;
    if (passwordStrength <= 0.25) return theme.colorScheme.error;
    if (passwordStrength <= 0.5) return Color(0xFFF57C00);
    if (passwordStrength <= 0.75) return Color(0xFFFFD700);
    return Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        // Full Name Field
        TextFormField(
          controller: fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your full name';
            }
            if (value.length < 3) {
              return 'Name must be at least 3 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Email Field
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@email.com',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'email',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            // Colombian domain validation (optional)
            final colombianDomains = ['.co', '.com.co', '.gov.co', '.edu.co'];
            final hasColombian = colombianDomains.any(
              (domain) => value.endsWith(domain),
            );
            if (!hasColombian && value.contains('@')) {
              // Allow international emails but show warning
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Phone Number Field
        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '+57 300 123 4567',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'phone',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
          ),
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s]')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            final cleanNumber = value.replaceAll(RegExp(r'[\s+]'), '');
            if (cleanNumber.length < 10) {
              return 'Please enter a valid Colombian phone number';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        // Password Field
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a strong password',
            prefixIcon: Padding(
              padding: EdgeInsets.all(12),
              child: CustomIconWidget(
                iconName: 'lock',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ),
            suffixIcon: IconButton(
              icon: CustomIconWidget(
                iconName: showPassword ? 'visibility_off' : 'visibility',
                color: theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          obscureText: !showPassword,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            return null;
          },
        ),
        SizedBox(height: 1.h),

        // Password Strength Indicator
        passwordController.text.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: passwordStrength,
                            backgroundColor: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getPasswordStrengthColor(context),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        _getPasswordStrengthText(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getPasswordStrengthColor(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Use 8+ characters with uppercase, numbers, and symbols',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
