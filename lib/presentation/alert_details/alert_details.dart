import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/supabase_service.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/comments_section_widget.dart';
import './widgets/emergency_contact_widget.dart';
import './widgets/incident_description_widget.dart';
import './widgets/incident_header_widget.dart';
import './widgets/incident_map_widget.dart';
import './widgets/media_gallery_widget.dart';
import './widgets/related_alerts_widget.dart';
import './widgets/reporter_info_widget.dart';
import './widgets/verification_section_widget.dart';

class AlertDetails extends StatefulWidget {
  const AlertDetails({super.key});

  @override
  State<AlertDetails> createState() => _AlertDetailsState();
}

class _AlertDetailsState extends State<AlertDetails> {
  bool _isLoading = true;
  String _loadError = '';
  bool _didLoad = false;
  bool _isOwner = false;
  bool _isUpdatingStatus = false;

  Map<String, dynamic> _alertData = {};
  List<Map<String, dynamic>> _mediaItems = [];
  Map<String, dynamic> _reporterData = {};
  List<Map<String, dynamic>> _relatedAlerts = [];
  List<Map<String, dynamic>> _comments = [];

  static const Map<String, String> _typeLabels = {
    'theft': 'Robo',
    'assault': 'Violencia',
    'suspicious': 'Actividad Sospechosa',
    'emergency': 'Emergencia',
    'vandalism': 'Vandalismo',
    'other': 'Otro',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) return;
    _didLoad = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final id = args['id'];
      if (id != null) {
        _loadIncident(id.toString());
      } else {
        setState(() {
          _isLoading = false;
          _loadError = 'Incidente no encontrado';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _loadError = 'No se recibieron datos del incidente';
      });
    }
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical': return 'CRÍTICO 🔴';
      case 'high':     return 'ALTO 🟠';
      case 'medium':   return 'MEDIO 🟡';
      default:         return 'BAJO 🟢';
    }
  }

  void _shareAlert() {
    final type = _alertData['type'] as String? ?? 'Incidente';
    final severity = _alertData['severity'] as String? ?? 'medium';
    final location = _alertData['location'] as String? ?? 'ubicación desconocida';
    SharePlus.instance.share(
      ShareParams(
        text: '🦇 BatFinder — Alerta de Seguridad\n\n'
            '🚨 Tipo: $type\n'
            '⚡ Nivel: ${_severityLabel(severity)}\n'
            '📍 Ubicación: $location\n\n'
            '⚠️ Comparte esta alerta para mantener a tu comunidad informada y segura.',
        subject: 'Alerta de Seguridad — BatFinder',
      ),
    );
  }

  bool _looksLikeCoordinates(String s) =>
      RegExp(r'^-?\d+\.?\d*,\s*-?\d+\.?\d*$').hasMatch(s.trim());

  Future<String?> _reverseGeocode(double lat, double lng) async {
    final dio = Dio();
    // Intento 1: Google Maps Geocoding (requiere API key)
    const apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (apiKey.isNotEmpty) {
      try {
        final response = await dio.get(
          'https://maps.googleapis.com/maps/api/geocode/json',
          queryParameters: {
            'latlng': '$lat,$lng',
            'key': apiKey,
            'language': 'es',
          },
        );
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          return results[0]['formatted_address'] as String?;
        }
      } catch (_) {}
    }
    // Intento 2: Nominatim (OpenStreetMap) — sin API key
    try {
      final response = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': '$lat',
          'lon': '$lng',
          'format': 'json',
          'accept-language': 'es',
        },
        options: Options(headers: {'User-Agent': 'BatFinder/1.0'}),
      );
      final address = response.data['address'] as Map<String, dynamic>?;
      if (address != null) {
        final neighbourhood = address['neighbourhood'] as String?
            ?? address['suburb'] as String?;
        final city = address['city'] as String?
            ?? address['town'] as String?
            ?? address['village'] as String?;
        final state = address['state'] as String?;
        final parts = [neighbourhood, city, state]
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {}
    return null;
  }

  Future<void> _loadIncident(String id) async {
    try {
      final data = await SupabaseService.getIncidentDetails(id);
      if (!mounted) return;

      if (data == null) {
        setState(() {
          _isLoading = false;
          _loadError = 'No se encontró el incidente';
        });
        return;
      }

      final incidentType = data['incident_type'] as String? ?? 'other';
      final createdAt = data['created_at'] as String?;
      final lat = (data['latitude'] as num?)?.toDouble() ?? 4.7110;
      final lng = (data['longitude'] as num?)?.toDouble() ?? -74.0721;

      var locationAddress = data['location_address'] as String? ?? '';
      if (locationAddress.isEmpty || _looksLikeCoordinates(locationAddress)) {
        final geocoded = await _reverseGeocode(lat, lng);
        if (geocoded != null) locationAddress = geocoded;
      }
      if (locationAddress.isEmpty || _looksLikeCoordinates(locationAddress)) {
        locationAddress =
            'Lat ${lat.toStringAsFixed(5)}, Lng ${lng.toStringAsFixed(5)}';
      }

      setState(() {
        _isOwner = data['reporter_id'] == SupabaseService.currentUserId;
        _alertData = {
          'id': data['id'],
          'type': _typeLabels[incidentType] ?? 'Incidente',
          'timestamp':
              createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
          'location': locationAddress,
          'distance': 'N/A',
          'latitude': lat,
          'longitude': lng,
          'description': data['description'] ?? '',
          'incident_type': incidentType,
          'severity': data['severity'] ?? 'medium',
          'status': data['status'] ?? 'active',
          'is_anonymous': data['is_anonymous'] ?? false,
        };

        final media = data['incident_media'] as List? ?? [];
        _mediaItems = media
            .map<Map<String, dynamic>>((m) => {
                  'type':
                      (m['media_type'] as String?) == 'video' ? 'video' : 'image',
                  'url': m['url'] as String? ?? '',
                  'semanticLabel':
                      m['description'] as String? ?? 'Imagen del incidente',
                })
            .toList();

        final reporter = data['reporter'] as Map<String, dynamic>?;
        _reporterData = {
          'isAnonymous': data['is_anonymous'] ?? false,
          'isVerified':
              (reporter?['verification_status'] as String?) == 'verified',
          'name': reporter?['full_name'] as String? ?? 'Usuario Anónimo',
          'avatar': reporter?['avatar_url'] as String? ?? '',
          'avatarSemanticLabel': 'Foto de perfil del reportero',
          'reputationScore': 0,
        };

        final commentsList = data['incident_comments'] as List? ?? [];
        _comments = commentsList
            .map<Map<String, dynamic>>((c) {
              final commenter = c['commenter'] as Map<String, dynamic>?;
              final commentAt = c['created_at'] as String?;
              return {
                'isAnonymous': commenter == null,
                'authorName':
                    commenter?['full_name'] as String? ?? 'Anónimo',
                'authorAvatar':
                    commenter?['avatar_url'] as String? ?? '',
                'authorAvatarSemanticLabel': 'Foto de perfil',
                'content': c['comment'] as String? ?? '',
                'timestamp': commentAt != null
                    ? DateTime.parse(commentAt)
                    : DateTime.now(),
              };
            })
            .toList();

        _relatedAlerts = [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Error al cargar el incidente';
        });
      }
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    final isResolved = newStatus == 'resolved';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isResolved ? 'Marcar como resuelto' : 'Falsa alarma'),
        content: Text(
          isResolved
              ? '¿Confirmas que la amenaza ya no está presente o el incidente fue atendido?'
              : '¿Confirmas que este reporte fue un error o una falsa alarma?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: isResolved
                ? null
                : ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(ctx).colorScheme.error,
                    foregroundColor: Theme.of(ctx).colorScheme.onError,
                  ),
            child: Text(isResolved ? 'Confirmar' : 'Sí, fue un error'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isUpdatingStatus = true);
    try {
      await SupabaseService.updateIncidentStatus(
        incidentId: _alertData['id'].toString(),
        status: newStatus,
      );
      if (mounted) {
        setState(() {
          _alertData = Map<String, dynamic>.from(_alertData)
            ..['status'] = newStatus;
          _isUpdatingStatus = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isResolved
                  ? 'Reporte marcado como resuelto.'
                  : 'Reporte marcado como falsa alarma.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar el estado.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Incidente')),
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    if (_loadError.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalles del Incidente')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: theme.colorScheme.error,
                size: 48,
              ),
              SizedBox(height: 2.h),
              Text(
                _loadError,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Incidente'),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _alertData.isEmpty ? null : _shareAlert,
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncidentHeaderWidget(alertData: _alertData),
            if (_isOwner && _alertData['status'] == 'active')
              _StatusManagementCard(
                isUpdating: _isUpdatingStatus,
                onResolved: () => _updateStatus('resolved'),
                onFalseAlarm: () => _updateStatus('false_alarm'),
              ),
            if (_alertData['status'] != 'active')
              _StatusBadge(status: _alertData['status'] as String),
            IncidentMapWidget(alertData: _alertData),
            if (_mediaItems.isNotEmpty) MediaGalleryWidget(mediaItems: _mediaItems),
            IncidentDescriptionWidget(
              description: _alertData['description'] as String? ?? '',
            ),
            ReporterInfoWidget(reporterData: _reporterData),
            VerificationSectionWidget(initialConfirms: 0, initialDisputes: 0),
            if (_relatedAlerts.isNotEmpty)
              RelatedAlertsWidget(relatedAlerts: _relatedAlerts),
            ActionButtonsWidget(alertData: _alertData, isAuthority: false),
            CommentsSectionWidget(comments: _comments),
            EmergencyContactWidget(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}

class _StatusManagementCard extends StatelessWidget {
  final bool isUpdating;
  final VoidCallback onResolved;
  final VoidCallback onFalseAlarm;

  const _StatusManagementCard({
    required this.isUpdating,
    required this.onResolved,
    required this.onFalseAlarm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.manage_history,
                  size: 18, color: theme.colorScheme.primary),
              SizedBox(width: 2.w),
              Text(
                'Gestionar mi reporte',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          if (isUpdating)
            Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onResolved,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Resuelto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      side: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFalseAlarm,
                    icon: const Icon(Icons.warning_amber_outlined, size: 18),
                    label: const Text('Falsa alarma'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResolved = status == 'resolved';
    final color =
        isResolved ? theme.colorScheme.primary : theme.colorScheme.error;
    final label = isResolved ? 'Resuelto' : 'Falsa alarma';
    final icon =
        isResolved ? Icons.check_circle : Icons.warning_amber_rounded;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 2.w),
          Text(
            'Este reporte fue marcado como: $label',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
