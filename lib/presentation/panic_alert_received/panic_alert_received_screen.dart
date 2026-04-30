import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/panic_alert_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/custom_image_widget.dart';

class PanicAlertReceivedScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const PanicAlertReceivedScreen({super.key, required this.data});

  @override
  State<PanicAlertReceivedScreen> createState() =>
      _PanicAlertReceivedScreenState();
}

class _PanicAlertReceivedScreenState
    extends State<PanicAlertReceivedScreen> {
  GoogleMapController? _mapController;

  Map<String, dynamic>? _senderProfile;
  LatLng? _senderLocation;
  final DateTime _receivedAt = DateTime.now();
  bool _isLoadingProfile = true;
  bool _locationLive = false;

  RealtimeChannel? _locationChannel;

  String get _eventId => widget.data['event_id'] as String? ?? '';
  String get _userId  => widget.data['user_id']  as String? ?? '';

  // Bogotá como fallback si no llega ubicación
  static const LatLng _defaultCenter = LatLng(4.7110, -74.0721);

  @override
  void initState() {
    super.initState();
    _initLocationFromPayload();
    _loadSenderProfile();
    if (_eventId.isNotEmpty) _subscribeToLocation();
  }

  void _initLocationFromPayload() {
    final lat = double.tryParse(widget.data['latitude']?.toString() ?? '');
    final lng = double.tryParse(widget.data['longitude']?.toString() ?? '');
    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      _senderLocation = LatLng(lat, lng);
    } else if (_eventId.isNotEmpty) {
      // Fallback: pedir la última posición guardada en Supabase
      SupabaseService.getLatestPanicLocation(_eventId).then((loc) {
        if (!mounted || loc == null) return;
        final la = (loc['latitude']  as num?)?.toDouble();
        final lo = (loc['longitude'] as num?)?.toDouble();
        if (la != null && lo != null) {
          setState(() => _senderLocation = LatLng(la, lo));
          _moveCameraTo(LatLng(la, lo));
        }
      });
    }
  }

  Future<void> _loadSenderProfile() async {
    if (_userId.isEmpty) {
      setState(() => _isLoadingProfile = false);
      return;
    }
    final profile = await SupabaseService.getSenderProfile(_userId);
    if (!mounted) return;
    setState(() {
      _senderProfile    = profile;
      _isLoadingProfile = false;
    });
  }

  void _subscribeToLocation() {
    _locationChannel = PanicAlertService().subscribeToLocation(
      _eventId,
      (data) {
        final lat = (data['latitude']  as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) return;
        final pos = LatLng(lat, lng);
        if (!mounted) return;
        setState(() {
          _senderLocation = pos;
          _locationLive   = true;
        });
        _moveCameraTo(pos);
      },
    );
  }

  void _moveCameraTo(LatLng pos) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
  }

  @override
  void dispose() {
    _locationChannel?.unsubscribe();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _callSender() async {
    final phone = _senderProfile?['phone'] as String?;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp() async {
    final phone = _senderProfile?['phone'] as String?;
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll('+', '').replaceAll(' ', '');
    final uri   = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final markers = _senderLocation == null
        ? <Marker>{}
        : {
            Marker(
              markerId: const MarkerId('sender'),
              position: _senderLocation!,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: _senderProfile?['full_name'] as String? ?? 'Usuario',
              ),
            ),
          };

    final initialCamera = CameraPosition(
      target: _senderLocation ?? _defaultCenter,
      zoom:   _senderLocation != null ? 15 : 10,
    );

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCamera,
            markers:               markers,
            onMapCreated:          (c) => _mapController = c,
            myLocationEnabled:     true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled:   false,
          ),
          _TopBanner(onBack: () => Navigator.of(context).pop()),
          Positioned(
            bottom: 0,
            left:   0,
            right:  0,
            child:  _BottomCard(
              theme:            theme,
              senderProfile:    _senderProfile,
              isLoadingProfile: _isLoadingProfile,
              senderLocation:   _senderLocation,
              locationLive:     _locationLive,
              receivedAt:       _receivedAt,
              onCall:           _callSender,
              onWhatsApp:       _openWhatsApp,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Banner ────────────────────────────────────────────────────────

class _TopBanner extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBanner({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                padding:    EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color:        Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Container(
                padding:    EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                decoration: BoxDecoration(
                  color:        theme.colorScheme.error,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color:      theme.colorScheme.error.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset:     const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: theme.colorScheme.onError, size: 18),
                    SizedBox(width: 2.w),
                    Text(
                      'ALERTA DE PÁNICO',
                      style: TextStyle(
                        color:      theme.colorScheme.onError,
                        fontWeight: FontWeight.w800,
                        fontSize:   12.sp,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Card ───────────────────────────────────────────────────────

class _BottomCard extends StatelessWidget {
  final ThemeData              theme;
  final Map<String, dynamic>?  senderProfile;
  final bool                   isLoadingProfile;
  final LatLng?                senderLocation;
  final bool                   locationLive;
  final DateTime               receivedAt;
  final VoidCallback           onCall;
  final VoidCallback           onWhatsApp;

  const _BottomCard({
    required this.theme,
    required this.senderProfile,
    required this.isLoadingProfile,
    required this.senderLocation,
    required this.locationLive,
    required this.receivedAt,
    required this.onCall,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final name     = senderProfile?['full_name']  as String? ?? 'Usuario';
    final nick     = senderProfile?['nickname']   as String?;
    final avatar   = senderProfile?['avatar_url'] as String?;
    final phone    = senderProfile?['phone']      as String?;
    final hasPhone = phone != null && phone.isNotEmpty;

    final hour = receivedAt.hour.toString().padLeft(2, '0');
    final min  = receivedAt.minute.toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        color:        theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, -2)),
        ],
      ),
      padding: EdgeInsets.fromLTRB(5.w, 1.5.h, 5.w, 4.h),
      child: Column(
        mainAxisSize:       MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width:  10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:        theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Sender row
          if (isLoadingProfile)
            const Center(child: CircularProgressIndicator())
          else
            _SenderRow(
              theme:    theme,
              name:     name,
              nick:     nick,
              avatar:   avatar,
              timeStr:  '$hour:$min',
            ),

          SizedBox(height: 2.h),

          // Location status
          _LocationBadge(
            theme:          theme,
            senderLocation: senderLocation,
            locationLive:   locationLive,
          ),

          SizedBox(height: 2.h),

          // Action buttons
          if (!isLoadingProfile)
            hasPhone
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onCall,
                          icon:      const Icon(Icons.phone, size: 18),
                          label:     const Text('Llamar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(color: theme.colorScheme.primary),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onWhatsApp,
                          icon:      const Icon(Icons.chat_bubble_outline, size: 18),
                          label:     const Text('WhatsApp'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                            side: BorderSide(color: theme.colorScheme.secondary),
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Sin número de contacto registrado.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
        ],
      ),
    );
  }
}

// ── Sender Row ────────────────────────────────────────────────────────

class _SenderRow extends StatelessWidget {
  final ThemeData theme;
  final String    name;
  final String?   nick;
  final String?   avatar;
  final String    timeStr;

  const _SenderRow({
    required this.theme,
    required this.name,
    required this.nick,
    required this.avatar,
    required this.timeStr,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius:          28,
          backgroundColor: theme.colorScheme.errorContainer,
          child: avatar != null && avatar!.isNotEmpty
              ? ClipOval(
                  child: CustomImageWidget(
                    imageUrl: avatar,
                    width:    56,
                    height:   56,
                    fit:      BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: theme.colorScheme.onErrorContainer,
                  size: 28,
                ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (nick != null)
                Text(
                  '@$nick',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 12, color: theme.colorScheme.onSurfaceVariant),
                  SizedBox(width: 1.w),
                  Text(
                    'Recibida a las $timeStr',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Location Badge ────────────────────────────────────────────────────

class _LocationBadge extends StatelessWidget {
  final ThemeData theme;
  final LatLng?   senderLocation;
  final bool      locationLive;

  const _LocationBadge({
    required this.theme,
    required this.senderLocation,
    required this.locationLive,
  });

  @override
  Widget build(BuildContext context) {
    final hasLoc = senderLocation != null;
    return Container(
      width:   double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color:        theme.colorScheme.errorContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border:       Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasLoc ? Icons.location_on : Icons.location_off,
            color: theme.colorScheme.error,
            size:  18,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              hasLoc
                  ? '${senderLocation!.latitude.toStringAsFixed(5)}, '
                    '${senderLocation!.longitude.toStringAsFixed(5)}'
                  : 'Esperando ubicación...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          if (locationLive)
            Row(
              children: [
                SizedBox(width: 2.w),
                Container(
                  width:  8,
                  height: 8,
                  decoration: BoxDecoration(
                    color:  theme.colorScheme.secondary,
                    shape:  BoxShape.circle,
                  ),
                ),
                SizedBox(width: 1.w),
                Text(
                  'En vivo',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color:      theme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
