import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

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
    if (passwordStrength == 0.0) return 'Débil';
    if (passwordStrength <= 0.25) return 'Débil';
    if (passwordStrength <= 0.5) return 'Regular';
    if (passwordStrength <= 0.75) return 'Buena';
    return 'Fuerte';
  }

  Color _getPasswordStrengthColor(BuildContext context) {
    final theme = Theme.of(context);
    if (passwordStrength == 0.0) return theme.colorScheme.error;
    if (passwordStrength <= 0.25) return theme.colorScheme.error;
    if (passwordStrength <= 0.5) return theme.colorScheme.secondary;
    if (passwordStrength <= 0.75) return theme.colorScheme.tertiary;
    return theme.colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),

        TextFormField(
          controller: fullNameController,
          decoration: InputDecoration(
            labelText: 'Nombre Completo',
            hintText: 'Ingresa tu nombre completo',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
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
              return 'Por favor ingresa tu nombre completo';
            }
            if (value.length < 3) {
              return 'El nombre debe tener al menos 3 caracteres';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Correo Electrónico',
            hintText: 'ejemplo@correo.com',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
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
              return 'Por favor ingresa tu correo electrónico';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Por favor ingresa un correo válido';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        TextFormField(
          controller: phoneController,
          decoration: InputDecoration(
            labelText: 'Teléfono',
            hintText: '+57 300 123 4567',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
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
              return 'Por favor ingresa tu número de teléfono';
            }
            final cleanNumber = value.replaceAll(RegExp(r'[\s+]'), '');
            if (cleanNumber.length < 10) {
              return 'Por favor ingresa un número colombiano válido';
            }
            return null;
          },
        ),
        SizedBox(height: 2.h),

        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Crea una contraseña segura',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
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
              return 'Por favor ingresa una contraseña';
            }
            if (value.length < 8) {
              return 'La contraseña debe tener al menos 8 caracteres';
            }
            return null;
          },
        ),
        SizedBox(height: 1.h),

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
                    'Usa 8+ caracteres con mayúsculas, números y símbolos',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
