import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
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
  final Map<String, dynamic> _alertData = {
    'id': 1,
    'type': 'Theft',
    'timestamp': DateTime.now().subtract(Duration(hours: 2)),
    'location': 'Carrera 7 #32-16, Bogotá',
    'distance': 1.2,
    'latitude': 4.7110,
    'longitude': -74.0721,
    'description':
        'Se reportó el robo de un celular a mano armada cerca de la estación de TransMilenio. El sospechoso huyó hacia el norte en una motocicleta roja. Las autoridades fueron notificadas y están patrullando el área.',
  };

  final List<Map<String, dynamic>> _mediaItems = [
    {
      'type': 'image',
      'url': 'https://images.unsplash.com/photo-1697420985296-c8be632cb740',
      'semanticLabel':
          'Street view showing the incident location near TransMilenio station with people walking',
    },
    {
      'type': 'image',
      'url':
          'https://images.unsplash.com/photo-1632927062611-68037fee9f2f',
      'semanticLabel':
          'Close-up photo of red motorcycle similar to suspect vehicle parked on street',
    },
    {
      'type': 'video',
      'url': 'https://images.unsplash.com/photo-1591732727204-5a9e1c718dc7',
      'semanticLabel':
          'Security camera footage thumbnail showing crowded street intersection',
    },
  ];

  final Map<String, dynamic> _reporterData = {
    'isAnonymous': false,
    'isVerified': true,
    'name': 'Carlos Rodríguez',
    'avatar':
        'https://img.rocket.new/generatedImages/rocket_gen_img_1137886c8-1763293866701.png',
    'avatarSemanticLabel':
        'Profile photo of Hispanic man with short black hair wearing blue shirt',
    'reputationScore': 87,
  };

  final List<Map<String, dynamic>> _relatedAlerts = [
    {
      'type': 'Suspicious Activity',
      'location': 'Calle 26 #13-19',
      'timestamp': DateTime.now().subtract(Duration(hours: 5)),
      'distance': 0.8,
    },
    {
      'type': 'Theft',
      'location': 'Carrera 10 #27-51',
      'timestamp': DateTime.now().subtract(Duration(hours: 8)),
      'distance': 1.5,
    },
    {
      'type': 'Violence',
      'location': 'Avenida Jiménez #7-65',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'distance': 2.1,
    },
  ];

  final List<Map<String, dynamic>> _comments = [
    {
      'isAnonymous': false,
      'authorName': 'María González',
      'authorAvatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_10cbd76d2-1763294189634.png',
      'authorAvatarSemanticLabel':
          'Profile photo of Hispanic woman with long brown hair wearing red top',
      'content':
          'Vi el mismo sospechoso cerca de la Universidad Nacional hace una hora. Tengan cuidado en esa zona.',
      'timestamp': DateTime.now().subtract(Duration(minutes: 45)),
    },
    {
      'isAnonymous': true,
      'content':
          'Las autoridades ya están patrullando el área. Gracias por reportar esto rápidamente.',
      'timestamp': DateTime.now().subtract(Duration(hours: 1)),
    },
    {
      'isAnonymous': false,
      'authorName': 'Juan Pérez',
      'authorAvatar':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1d7a6ad8f-1763293689395.png',
      'authorAvatarSemanticLabel':
          'Profile photo of Hispanic man with glasses and beard wearing gray sweater',
      'content':
          'Recomiendo evitar esa zona después de las 6 PM. Ha habido varios incidentes similares esta semana.',
      'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Alert Details'),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'share',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Share functionality activated')),
              );
            },
            tooltip: 'Share Alert',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IncidentHeaderWidget(alertData: _alertData),
            IncidentMapWidget(alertData: _alertData),
            MediaGalleryWidget(mediaItems: _mediaItems),
            IncidentDescriptionWidget(
              description: _alertData['description'] ?? '',
            ),
            ReporterInfoWidget(reporterData: _reporterData),
            VerificationSectionWidget(initialConfirms: 42, initialDisputes: 3),
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
