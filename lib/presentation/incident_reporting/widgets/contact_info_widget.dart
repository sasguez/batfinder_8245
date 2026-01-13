import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for optional contact information with Colombian phone format
class ContactInfoWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final String? phoneError;
  final bool isAnonymous;

  const ContactInfoWidget({
    super.key,
    required this.phoneController,
    this.phoneError,
    required this.isAnonymous,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Información de Contacto',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Opcional',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.5.h),
        TextField(
          controller: phoneController,
          enabled: !isAnonymous,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: InputDecoration(
            hintText: '3001234567',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'phone',
                color: isAnonymous
                    ? theme.colorScheme.onSurfaceVariant
                    : theme.colorScheme.primary,
                size: 20,
              ),
            ),
            prefixText: '+57 ',
            errorText: phoneError,
            enabled: !isAnonymous,
          ),
        ),
        if (isAnonymous) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  'Deshabilitado en modo anónimo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
