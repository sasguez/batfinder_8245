import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MapFilterSheetWidget extends StatefulWidget {
  final List<String> selectedTypes;
  final List<String> selectedSeverities;
  final List<String> selectedStatuses;
  final Function(List<String>, List<String>, List<String>) onApplyFilters;

  const MapFilterSheetWidget({
    super.key,
    required this.selectedTypes,
    required this.selectedSeverities,
    required this.selectedStatuses,
    required this.onApplyFilters,
  });

  @override
  State<MapFilterSheetWidget> createState() => _MapFilterSheetWidgetState();
}

class _MapFilterSheetWidgetState extends State<MapFilterSheetWidget> {
  late List<String> _types;
  late List<String> _severities;
  late List<String> _statuses;

  final List<String> _availableTypes = [
    'robo',
    'asalto',
    'vandalismo',
    'infraestructura',
    'accidente',
    'otro',
  ];

  final List<String> _availableSeverities = [
    'low',
    'medium',
    'high',
    'critical',
  ];
  final List<String> _availableStatuses = [
    'pending',
    'verified',
    'in_progress',
    'resolved',
  ];

  @override
  void initState() {
    super.initState();
    _types = List.from(widget.selectedTypes);
    _severities = List.from(widget.selectedSeverities);
    _statuses = List.from(widget.selectedStatuses);
  }

  String _getTypeLabel(String type) {
    final labels = {
      'robo': 'Robo',
      'asalto': 'Asalto',
      'vandalismo': 'Vandalismo',
      'infraestructura': 'Infraestructura',
      'accidente': 'Accidente',
      'otro': 'Otro',
    };
    return labels[type] ?? type;
  }

  String _getSeverityLabel(String severity) {
    final labels = {
      'low': 'Baja',
      'medium': 'Media',
      'high': 'Alta',
      'critical': 'Crítica',
    };
    return labels[severity] ?? severity;
  }

  String _getStatusLabel(String status) {
    final labels = {
      'pending': 'Pendiente',
      'verified': 'Verificado',
      'in_progress': 'En Progreso',
      'resolved': 'Resuelto',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtros de Mapa',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tipo de Incidente',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _availableTypes.map((type) {
                      final isSelected = _types.contains(type);
                      return FilterChip(
                        label: Text(_getTypeLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _types.add(type);
                            } else {
                              _types.remove(type);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 2.h),
                  Text(
                    'Severidad',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _availableSeverities.map((severity) {
                      final isSelected = _severities.contains(severity);
                      return FilterChip(
                        label: Text(_getSeverityLabel(severity)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _severities.add(severity);
                            } else {
                              _severities.remove(severity);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 2.h),
                  Text(
                    'Estado',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _availableStatuses.map((status) {
                      final isSelected = _statuses.contains(status);
                      return FilterChip(
                        label: Text(_getStatusLabel(status)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _statuses.add(status);
                            } else {
                              _statuses.remove(status);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _types.clear();
                        _severities.clear();
                        _statuses.clear();
                      });
                    },
                    child: const Text('Limpiar'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(_types, _severities, _statuses);
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
