import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Language Section Widget
/// Language selection with Colombian Spanish variants
class LanguageSectionWidget extends StatefulWidget {
  const LanguageSectionWidget({super.key});

  @override
  State<LanguageSectionWidget> createState() => _LanguageSectionWidgetState();
}

class _LanguageSectionWidgetState extends State<LanguageSectionWidget> {
  String _selectedLanguage = 'Español (Colombia)';

  final List<Map<String, String>> languages = [
    {"name": "Español (Colombia)", "code": "es-CO"},
    {"name": "Español (Estándar)", "code": "es"},
    {"name": "Wayuunaiki", "code": "guc"},
    {"name": "Nasa Yuwe", "code": "pbb"},
    {"name": "English", "code": "en"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Idioma',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Incluye integración con servicios de emergencia regionales',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 1),

          // Language Options
          ...languages.asMap().entries.map((entry) {
            final index = entry.key;
            final language = entry.value;
            final isLast = index == languages.length - 1;

            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() => _selectedLanguage = language["name"]!);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'language',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            language["name"]!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: _selectedLanguage == language["name"]
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        _selectedLanguage == language["name"]
                            ? CustomIconWidget(
                                iconName: 'check_circle',
                                color: theme.colorScheme.primary,
                                size: 24,
                              )
                            : SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
                isLast
                    ? SizedBox.shrink()
                    : Divider(height: 1, thickness: 1, indent: 16.w),
              ],
            );
          }),
        ],
      ),
    );
  }
}
