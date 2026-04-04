import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/incident_management_service.dart';
import '../../widgets/custom_app_bar.dart';

class CreateEditIncidentScreen extends StatefulWidget {
  final String? incidentId;
  final Map<String, dynamic>? existingIncident;

  const CreateEditIncidentScreen({
    super.key,
    this.incidentId,
    this.existingIncident,
  });

  @override
  State<CreateEditIncidentScreen> createState() =>
      _CreateEditIncidentScreenState();
}

class _CreateEditIncidentScreenState extends State<CreateEditIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incidentService = IncidentManagementService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedType = 'robo';
  String _selectedSeverity = 'medium';
  DateTime _occurredAt = DateTime.now();
  bool _isAnonymous = false;
  bool _isLoading = false;

  Position? _currentPosition;
  double? _latitude;
  double? _longitude;

  final List<Map<String, String>> _incidentTypes = [
    {'value': 'robo', 'label': 'Robo'},
    {'value': 'asalto', 'label': 'Asalto'},
    {'value': 'vandalismo', 'label': 'Vandalismo'},
    {'value': 'infraestructura', 'label': 'Infraestructura'},
    {'value': 'accidente', 'label': 'Accidente'},
    {'value': 'otro', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _severities = [
    {'value': 'low', 'label': 'Baja'},
    {'value': 'medium', 'label': 'Media'},
    {'value': 'high', 'label': 'Alta'},
    {'value': 'critical', 'label': 'Crítica'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingIncident != null) {
      _loadExistingIncident();
    } else {
      _getCurrentLocation();
    }
  }

  void _loadExistingIncident() {
    final incident = widget.existingIncident!;
    _titleController.text = incident['title'];
    _descriptionController.text = incident['description'];
    _addressController.text = incident['location_address'] ?? '';
    _selectedType = incident['incident_type'];
    _selectedSeverity = incident['severity'];
    _latitude = incident['location_lat'];
    _longitude = incident['location_lng'];
    _occurredAt = DateTime.parse(incident['occurred_at']);
    _isAnonymous = incident['is_anonymous'] ?? false;
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Los servicios de ubicación están desactivados'),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
        setState(() {
          _latitude = _currentPosition!.latitude;
          _longitude = _currentPosition!.longitude;
        });
      }
    } catch (e) {
      print('Error obteniendo ubicación: $e');
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_occurredAt),
      );

      if (time != null) {
        setState(() {
          _occurredAt = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveIncident() async {
    if (!_formKey.currentState!.validate()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, obtén tu ubicación primero')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.incidentId != null) {
        await _incidentService.updateIncident(
          incidentId: widget.incidentId!,
          title: _titleController.text,
          description: _descriptionController.text,
          severity: _selectedSeverity,
          locationLat: _latitude,
          locationLng: _longitude,
          locationAddress: _addressController.text.isEmpty
              ? null
              : _addressController.text,
        );
      } else {
        await _incidentService.createIncident(
          title: _titleController.text,
          description: _descriptionController.text,
          incidentType: _selectedType,
          severity: _selectedSeverity,
          locationLat: _latitude!,
          locationLng: _longitude!,
          locationAddress: _addressController.text.isEmpty
              ? null
              : _addressController.text,
          occurredAt: _occurredAt,
          isAnonymous: _isAnonymous,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.incidentId != null
                  ? 'Incidente actualizado exitosamente'
                  : 'Incidente creado exitosamente',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.incidentId != null
            ? 'Editar Incidente'
            : 'Crear Incidente',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese un título';
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingrese una descripción';
                }
                return null;
              },
            ),

            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Incidente',
                border: OutlineInputBorder(),
              ),
              items: _incidentTypes.map((type) {
                return DropdownMenuItem(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),

            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              initialValue: _selectedSeverity,
              decoration: const InputDecoration(
                labelText: 'Severidad',
                border: OutlineInputBorder(),
              ),
              items: _severities.map((severity) {
                return DropdownMenuItem(
                  value: severity['value'],
                  child: Text(severity['label']!),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedSeverity = value);
                }
              },
            ),

            SizedBox(height: 2.h),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha y Hora del Incidente'),
              subtitle: Text(
                '${_occurredAt.day}/${_occurredAt.month}/${_occurredAt.year} ${_occurredAt.hour}:${_occurredAt.minute.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDateTime,
            ),

            SizedBox(height: 2.h),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Dirección (opcional)',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 2.h),
            if (_latitude != null && _longitude != null)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Ubicación obtenida: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                        style: TextStyle(color: Colors.green.shade900),
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Obtener Ubicación Actual'),
              ),

            SizedBox(height: 2.h),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Reportar de forma anónima'),
              value: _isAnonymous,
              onChanged: (value) {
                setState(() => _isAnonymous = value ?? false);
              },
            ),

            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveIncident,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.incidentId != null
                            ? 'Actualizar'
                            : 'Crear Incidente',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
