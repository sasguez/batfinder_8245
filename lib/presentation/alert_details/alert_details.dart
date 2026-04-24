import 'package:flutter/material.dart';
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

  Map<String, dynamic> _alertData = {};
  List<Map<String, dynamic>> _mediaItems = [];
  Map<String, dynamic> _reporterData = {};
  List<Map<String, dynamic>> _relatedAlerts = [];
  List<Map<String, dynamic>> _comments = [];

  static const Map<String, String> _typeLabels = {
    'theft': 'Robo',
    'assault': 'Agresión',
    'suspicious_activity': 'Actividad Sospechosa',
    'emergency': 'Emergencia',
    'accident': 'Accidente',
    'fire': 'Incendio',
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

      setState(() {
        _alertData = {
          'id': data['id'],
          'type': _typeLabels[incidentType] ?? 'Incidente',
          'timestamp':
              createdAt != null ? DateTime.parse(createdAt) : DateTime.now(),
          'location': data['location_address'] ?? 'Ubicación no especificada',
          'distance': 'N/A',
          'latitude': (data['latitude'] as num?)?.toDouble() ?? 4.7110,
          'longitude': (data['longitude'] as num?)?.toDouble() ?? -74.0721,
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir disponible próximamente')),
              );
            },
            tooltip: 'Compartir',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncidentHeaderWidget(alertData: _alertData),
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
