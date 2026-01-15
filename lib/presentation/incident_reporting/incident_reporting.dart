import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../services/incident_management_service.dart';
import '../../services/offline_queue_service.dart';
import './widgets/anonymous_toggle_widget.dart';
import './widgets/contact_info_widget.dart';
import './widgets/datetime_selector_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/incident_type_selector_widget.dart';
import './widgets/location_selector_widget.dart';
import './widgets/media_attachment_widget.dart';
import './widgets/severity_slider_widget.dart';

/// Incident Reporting Screen
/// Enables users to document and submit safety incidents with multimedia evidence
class IncidentReporting extends StatefulWidget {
  const IncidentReporting({super.key});

  @override
  State<IncidentReporting> createState() => _IncidentReportingState();
}

class _IncidentReportingState extends State<IncidentReporting> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _incidentService = IncidentManagementService();
  final _offlineQueue = OfflineQueueService();

  String? _selectedIncidentType;
  DateTime _selectedDateTime = DateTime.now();
  int _severity = 3;
  bool _isAnonymous = false;
  List<XFile> _attachedMedia = [];
  bool _isLoadingLocation = true;
  String _locationText = 'Obteniendo ubicación...';
  bool _isSubmitting = false;
  String? _descriptionError;
  String? _phoneError;
  bool _isOnline = true;
  Map<String, int> _queueStats = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _loadDraft();
    _initializeOfflineQueue();
    _listenToQueueStatus();
  }

  Future<void> _initializeOfflineQueue() async {
    await _offlineQueue.initialize();
    final online = await _offlineQueue.isOnline();
    final stats = await _offlineQueue.getQueueStats();
    if (mounted) {
      setState(() {
        _isOnline = online;
        _queueStats = stats;
      });
    }
  }

  void _listenToQueueStatus() {
    _offlineQueue.queueStatusStream.listen((data) {
      if (mounted) {
        setState(() {
          _queueStats = data['stats'] as Map<String, int>;
        });
      }
    });
  }

  Future<void> _loadCurrentLocation() async {
    await Future.delayed(Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _locationText = 'Calle 72 #10-34, Bogotá, Colombia';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadDraft() async {
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> _saveDraft() async {
    await Future.delayed(Duration(milliseconds: 300));
  }

  bool _validateForm() {
    bool isValid = true;

    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un tipo de incidente')),
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

  Future<void> _submitReport() async {
    if (!_validateForm()) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await _incidentService.createIncident(
        title: '${_selectedIncidentType ?? 'Incidente'} - $_locationText',
        description: _descriptionController.text.trim(),
        incidentType: _selectedIncidentType ?? 'general',
        severity: _getSeverityString(_severity),
        locationLat: 19.432608,
        locationLng: -99.133209,
        locationAddress: _locationText,
        occurredAt: _selectedDateTime,
        isAnonymous: _isAnonymous,
        mediaUrls: _attachedMedia.map((file) => file.path).toList(),
      );

      if (mounted) {
        final reportId = result['id'] as String;
        final isQueued = result['is_queued'] == true;
        _showSuccessDialog(reportId, isQueued: isQueued);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al enviar el reporte. Se guardó para enviar después.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getSeverityString(int value) {
    if (value <= 2) return 'low';
    if (value <= 3) return 'medium';
    if (value <= 4) return 'high';
    return 'critical';
  }

  void _showSuccessDialog(String reportId, {bool isQueued = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Row(
            children: [
              CustomIconWidget(
                iconName: isQueued ? 'schedule' : 'check_circle',
                color: isQueued ? Color(0xFFFF9800) : Color(0xFF4CAF50),
                size: 28,
              ),
              SizedBox(width: 2.w),
              Text(isQueued ? 'Reporte en Cola' : 'Reporte Enviado'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isQueued
                    ? 'Tu reporte se guardó y se enviará automáticamente cuando recuperes la conexión.'
                    : 'Tu reporte ha sido enviado exitosamente.',
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
              if (!isQueued) ...[
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
                        'Tiempo estimado de respuesta: 15-30 minutos',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamed('/alert-dashboard');
              },
              child: Text('Ver Alertas'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pendingCount = _queueStats['pending'] ?? 0;
    final failedCount = _queueStats['failed'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () async {
            await _saveDraft();
            if (mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
        title: Text('Reportar Incidente'),
        actions: [
          if (!_isOnline)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_off',
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Sin conexión',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          if (pendingCount > 0 || failedCount > 0)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: failedCount > 0
                        ? theme.colorScheme.errorContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${pendingCount + failedCount} en cola',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: failedCount > 0
                          ? theme.colorScheme.onErrorContainer
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
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
              onTypeSelected: (type) {
                setState(() => _selectedIncidentType = type);
              },
            ),
            SizedBox(height: 3.h),
            LocationSelectorWidget(
              locationText: _locationText,
              isLoadingLocation: _isLoadingLocation,
              onAdjustLocation: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ajustar ubicación en el mapa')),
                );
              },
            ),
            SizedBox(height: 3.h),
            DateTimeSelectorWidget(
              selectedDateTime: _selectedDateTime,
              onDateTimeChanged: (dateTime) {
                setState(() => _selectedDateTime = dateTime);
              },
            ),
            SizedBox(height: 3.h),
            DescriptionInputWidget(
              controller: _descriptionController,
              errorText: _descriptionError,
            ),
            SizedBox(height: 3.h),
            MediaAttachmentWidget(
              attachedMedia: _attachedMedia,
              onMediaChanged: (media) {
                setState(() => _attachedMedia = media);
              },
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
              onSeverityChanged: (value) {
                setState(() => _severity = value);
              },
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
                        Text('Enviando...'),
                      ],
                    )
                  : Text('Enviar Reporte'),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
