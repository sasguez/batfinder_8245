import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Widget for selecting incident severity with visual indicators
class SeveritySliderWidget extends StatelessWidget {
  final int severity;
  final Function(int) onSeverityChanged;

  const SeveritySliderWidget({
    super.key,
    required this.severity,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> severityLevels = [
      {'level': 1, 'label': 'Bajo', 'color': Color(0xFF4CAF50)},
      {'level': 2, 'label': 'Moderado', 'color': Color(0xFF8BC34A)},
      {'level': 3, 'label': 'Medio', 'color': Color(0xFFFFC107)},
      {'level': 4, 'label': 'Alto', 'color': Color(0xFFFF9800)},
      {'level': 5, 'label': 'Crítico', 'color': Color(0xFFF44336)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nivel de Urgencia',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.5.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outline, width: 1),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: severityLevels.map((level) {
                  final isSelected = severity == level['level'];
                  return Column(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? level['color']
                              : (level['color'] as Color).withValues(
                                  alpha: 0.2,
                                ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: level['color'],
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            level['level'].toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isSelected ? Colors.white : level['color'],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        level['label'],
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? level['color']
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              SizedBox(height: 2.h),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: severityLevels[severity - 1]['color'],
                  thumbColor: severityLevels[severity - 1]['color'],
                  overlayColor: (severityLevels[severity - 1]['color'] as Color)
                      .withValues(alpha: 0.2),
                  inactiveTrackColor: theme.colorScheme.outline,
                  trackHeight: 4.0,
                ),
                child: Slider(
                  value: severity.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) => onSeverityChanged(value.toInt()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
