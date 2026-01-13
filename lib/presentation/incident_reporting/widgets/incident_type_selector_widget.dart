import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget for selecting incident type with large, thumb-friendly buttons
class IncidentTypeSelectorWidget extends StatelessWidget {
  final String? selectedType;
  final Function(String) onTypeSelected;

  const IncidentTypeSelectorWidget({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> incidentTypes = [
      {
        'type': 'Robo',
        'icon': 'shopping_bag',
        'color': theme.colorScheme.error,
      },
      {'type': 'Violencia', 'icon': 'warning', 'color': Color(0xFFD32F2F)},
      {
        'type': 'Actividad Sospechosa',
        'icon': 'visibility',
        'color': Color(0xFFF57C00),
      },
      {
        'type': 'Emergencia',
        'icon': 'emergency',
        'color': theme.colorScheme.primary,
      },
      {
        'type': 'Otro',
        'icon': 'more_horiz',
        'color': theme.colorScheme.secondary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Incidente',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.5.h,
          children: incidentTypes.map((incident) {
            final isSelected = selectedType == incident['type'];
            return InkWell(
              onTap: () => onTypeSelected(incident['type']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 28.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (incident['color'] as Color).withValues(alpha: 0.15)
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? incident['color']
                        : theme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: incident['icon'],
                      color: isSelected
                          ? incident['color']
                          : theme.colorScheme.onSurfaceVariant,
                      size: 32,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      incident['type'],
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? incident['color']
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
