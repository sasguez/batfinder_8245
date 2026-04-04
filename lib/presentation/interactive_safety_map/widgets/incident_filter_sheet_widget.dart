import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Incident Filter Sheet Widget
/// Provides filtering options for incidents by time range, type, and severity
class IncidentFilterSheetWidget extends StatefulWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> incidents;
  final Function(Map<String, dynamic>) onFilterApplied;

  const IncidentFilterSheetWidget({
    super.key,
    required this.scrollController,
    required this.incidents,
    required this.onFilterApplied,
  });

  @override
  State<IncidentFilterSheetWidget> createState() =>
      _IncidentFilterSheetWidgetState();
}

class _IncidentFilterSheetWidgetState extends State<IncidentFilterSheetWidget> {
  String _selectedTimeRange = 'Última hora';
  final Set<String> _selectedTypes = {};
  final Set<String> _selectedSeverities = {};

  final List<String> _timeRanges = [
    'Última hora',
    'Últimas 6 horas',
    'Últimas 24 horas',
    'Última semana',
  ];

  final List<Map<String, dynamic>> _incidentTypes = [
    {"label": "Robo", "icon": "local_police"},
    {"label": "Violencia", "icon": "warning"},
    {"label": "Actividad Sospechosa", "icon": "visibility"},
    {"label": "Vandalismo", "icon": "broken_image"},
  ];

  final List<Map<String, dynamic>> _severityLevels = [
    {"label": "Crítico", "value": "critical", "color": Colors.red},
    {"label": "Alto", "value": "high", "color": Colors.orange},
    {"label": "Medio", "value": "medium", "color": Colors.yellow},
    {"label": "Bajo", "value": "low", "color": Colors.green},
  ];

  void _applyFilters() {
    widget.onFilterApplied({
      "timeRange": _selectedTimeRange,
      "types": _selectedTypes.toList(),
      "severities": _selectedSeverities.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      children: [
        Text('Filtros de Incidentes', style: theme.textTheme.titleLarge),
        SizedBox(height: 2.h),
        Text('Rango de Tiempo', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _timeRanges.map((range) {
            final isSelected = _selectedTimeRange == range;
            return ChoiceChip(
              label: Text(range),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedTimeRange = range);
                _applyFilters();
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 3.h),
        Text('Tipo de Incidente', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _incidentTypes.map((type) {
            final isSelected = _selectedTypes.contains(type["label"]);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: type["icon"] as String,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                    size: 18,
                  ),
                  SizedBox(width: 1.w),
                  Text(type["label"] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected
                      ? _selectedTypes.add(type["label"] as String)
                      : _selectedTypes.remove(type["label"]);
                });
                _applyFilters();
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 3.h),
        Text('Nivel de Severidad', style: theme.textTheme.titleMedium),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _severityLevels.map((severity) {
            final isSelected = _selectedSeverities.contains(severity["value"]);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: severity["color"] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  Text(severity["label"] as String),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selected
                      ? _selectedSeverities.add(severity["value"] as String)
                      : _selectedSeverities.remove(severity["value"]);
                });
                _applyFilters();
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedTimeRange = 'Última hora';
                    _selectedTypes.clear();
                    _selectedSeverities.clear();
                  });
                  _applyFilters();
                },
                child: Text('Limpiar Filtros'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Aplicar'),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Divider(),
        SizedBox(height: 2.h),
        Text(
          'Incidentes Recientes (${widget.incidents.length})',
          style: theme.textTheme.titleMedium,
        ),
        SizedBox(height: 1.h),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: widget.incidents.length > 5 ? 5 : widget.incidents.length,
          separatorBuilder: (context, index) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final incident = widget.incidents[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSeverityColor(incident["severity"] as String),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  incident["title"] as String,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  incident["type"] as String,
                  style: theme.textTheme.bodySmall,
                ),
                trailing: Text(
                  _formatTimestamp(incident["timestamp"] as DateTime),
                  style: theme.textTheme.bodySmall,
                ),
                onTap: () {
                  Navigator.of(
                    context,
                    rootNavigator: true,
                  ).pushNamed('/alert-details');
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case "critical":
        return Colors.red;
      case "high":
        return Colors.orange;
      case "medium":
        return Colors.yellow;
      case "low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else {
      return 'Hace ${difference.inDays} d';
    }
  }
}
