import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/anonymous_toggle_widget.dart';
import './widgets/contact_info_widget.dart';
import './widgets/datetime_selector_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/incident_type_selector_widget.dart';
import './widgets/location_picker_page.dart';
import './widgets/location_selector_widget.dart';
import './widgets/media_attachment_widget.dart';
import './widgets/severity_slider_widget.dart';

class IncidentReporting extends StatefulWidget {
  const IncidentReporting({super.key});

  @override
  State<IncidentReporting> createState() => _IncidentReportingState();
}

class _IncidentReportingState extends State<IncidentReporting> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dio = Dio();

  String? _selectedIncidentType;
  DateTime _selectedDateTime = DateTime.now();
  int _severity = 3;
  bool _isAnonymous = false;
  List<XFile> _attachedMedia = [];
  bool _isLoadingLocation = true;
  String _locationText = 'Obteniendo ubicación...';
  double? _latitude;
  double? _longitude;
  bool _isSubmitting = false;
  String? _descriptionError;
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationText = 'Servicio de ubicación desactivado';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _locationText = 'Permiso de ubicación denegado';
              _isLoadingLocation = false;
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationText = 'Activa la ubicación en Configuración';
            _isLoadingLocation = false;
          });
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      final address = await _reverseGeocode(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _locationText = address;
          _isLoadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationText = 'No se pudo obtener la ubicación';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
      if (apiKey.isEmpty) {
        return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
      }
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'latlng': '$lat,$lng',
          'key': apiKey,
          'language': 'es',
        },
      );
      final results = response.data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        return results[0]['formatted_address'] as String;
      }
    } catch (_) {}
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  Future<void> _openLocationPicker() async {
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Espera a que se obtenga la ubicación.')),
      );
      return;
    }
    final result = await Navigator.of(context, rootNavigator: true).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerPage(
          initialPosition: LatLng(_latitude!, _longitude!),
        ),
        fullscreenDialog: true,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _isLoadingLocation = true;
        _locationText = 'Actualizando dirección...';
      });
      final address = await _reverseGeocode(result.latitude, result.longitude);
      if (mounted) {
        setState(() {
          _locationText = address;
          _isLoadingLocation = false;
        });
      }
    }
  }

  bool _validateForm() {
    bool isValid = true;

    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un tipo de incidente')),
      );
      isValid = false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      setState(() => _descriptionError = 'La descripción es requerida');
      isValid = false;
    } else if (_descriptionController.text.trim().length < 10) {
      setState(() => _descriptionError = 'Mínimo 10 caracteres requeridos');
      isValid = false;
    } else {
      setState(() => _descriptionError = null);
    }

    if (!_isAnonymous && _phoneController.text.isNotEmpty) {
      if (_phoneController.text.length != 10) {
        setState(() => _phoneError = 'Número de teléfono inválido');
        isValid = false;
      } else {
        setState(() => _phoneError = null);
      }
    }

    return isValid;
  }

  String _toEnglishType(String spanishType) {
    switch (spanishType) {
      case 'Robo':                 return 'theft';
      case 'Violencia':            return 'assault';
      case 'Actividad Sospechosa': return 'suspicious';
      case 'Emergencia':           return 'emergency';
      default:                     return 'other';
    }
  }

  String _toSeverityString(int level) {
    if (level <= 2) return 'low';
    if (level == 3) return 'medium';
    if (level == 4) return 'high';
    return 'critical';
  }

  Future<void> _submitReport() async {
    if (!_validateForm()) return;

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Espera a que se obtenga la ubicación e intenta de nuevo.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final incidentId = await SupabaseService.createIncident(
        title: 'Reporte de ${_selectedIncidentType!}',
        description: _descriptionController.text.trim(),
        incidentType: _toEnglishType(_selectedIncidentType!),
        severity: _toSeverityString(_severity),
        latitude: _latitude!,
        longitude: _longitude!,
        locationAddress: _locationText,
        isAnonymous: _isAnonymous,
      );

      if (mounted) _showSuccessDialog(incidentId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al enviar el reporte. Intenta nuevamente.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String reportId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              const CustomIconWidget(
                iconName: 'check_circle',
                color: Color(0xFF4CAF50),
                size: 28,
              ),
              SizedBox(width: 2.w),
              const Text('Reporte Enviado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu reporte ha sido registrado y ya es visible para tu comunidad.',
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID del Reporte:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      reportId,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Tiempo estimado de respuesta: 15–30 minutos',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed('/alert-dashboard');
              },
              child: const Text('Ver Alertas'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _phoneController.dispose();
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () {
            if (mounted) Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        title: const Text('Reportar Incidente'),
        actions: [
          if (_isSubmitting)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            IncidentTypeSelectorWidget(
              selectedType: _selectedIncidentType,
              onTypeSelected: (type) => setState(() => _selectedIncidentType = type),
            ),
            SizedBox(height: 3.h),
            LocationSelectorWidget(
              locationText: _locationText,
              isLoadingLocation: _isLoadingLocation,
              latitude: _latitude,
              longitude: _longitude,
              onAdjustLocation: _openLocationPicker,
            ),
            SizedBox(height: 3.h),
            DateTimeSelectorWidget(
              selectedDateTime: _selectedDateTime,
              onDateTimeChanged: (dateTime) =>
                  setState(() => _selectedDateTime = dateTime),
            ),
            SizedBox(height: 3.h),
            DescriptionInputWidget(
              controller: _descriptionController,
              errorText: _descriptionError,
            ),
            SizedBox(height: 3.h),
            MediaAttachmentWidget(
              attachedMedia: _attachedMedia,
              onMediaChanged: (media) => setState(() => _attachedMedia = media),
            ),
            SizedBox(height: 3.h),
            AnonymousToggleWidget(
              isAnonymous: _isAnonymous,
              onToggleChanged: (value) {
                setState(() {
                  _isAnonymous = value;
                  if (value) {
                    _phoneController.clear();
                    _phoneError = null;
                  }
                });
              },
            ),
            SizedBox(height: 3.h),
            SeveritySliderWidget(
              severity: _severity,
              onSeverityChanged: (value) => setState(() => _severity = value),
            ),
            SizedBox(height: 3.h),
            ContactInfoWidget(
              phoneController: _phoneController,
              phoneError: _phoneError,
              isAnonymous: _isAnonymous,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
              ),
              child: _isSubmitting
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        const Text('Enviando...'),
                      ],
                    )
                  : const Text('Enviar Reporte'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
