import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/panic_alert_service.dart';
import '../../services/power_button_detector_service.dart';
import '../../services/supabase_service.dart';
import './widgets/emergency_contacts_widget.dart';
import './widgets/emergency_header_widget.dart';
import './widgets/emergency_services_widget.dart';
import './widgets/location_display_widget.dart';
import './widgets/media_capture_widget.dart';

/// Emergency Panic Mode Screen
/// Provides immediate crisis response with automated safety protocols
class EmergencyPanicMode extends StatefulWidget {
  const EmergencyPanicMode({super.key});

  @override
  State<EmergencyPanicMode> createState() => _EmergencyPanicModeState();
}

class _EmergencyPanicModeState extends State<EmergencyPanicMode>
    with WidgetsBindingObserver {
  PowerButtonDetectorService? _powerDetector;

  // Emergency state
  int _remainingSeconds = 120; // 2 minutes default countdown
  Timer? _countdownTimer;
  bool _emergencyActive = true;

  // Location tracking
  double _latitude = 0.0;
  double _longitude = 0.0;
  double _accuracy = 0.0;
  StreamSubscription<Position>? _positionStream;

  // Audio recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String _recordingDuration = '00:00';
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  // Camera
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final ImagePicker _imagePicker = ImagePicker();

  // Contactos reales cargados desde Supabase
  List<Map<String, dynamic>> _emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeEmergencyMode();
    _loadAndStartDetector();
  }

  Future<void> _loadAndStartDetector() async {
    final prefs = await SharedPreferences.getInstance();
    final requiredTaps = prefs.getInt('power_button_required_taps') ?? 3;
    // 3 toques en pánico activo dispara la cancelación de la alerta
    _powerDetector = PowerButtonDetectorService(
      requiredTaps: requiredTaps,
      onTrigger: () => _cancelEmergencyMode(),
    );
    _powerDetector!.start();
  }

  @override
  void dispose() {
    _powerDetector?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    _positionStream?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ensure emergency mode continues in background
    if (state == AppLifecycleState.paused && _emergencyActive) {
      _showBackgroundNotification();
    }
  }

  Future<void> _initializeEmergencyMode() async {
    _startCountdownTimer();
    await _initializeLocationTracking();
    await _startAudioRecording();
    await _initializeCamera();

    await _loadEmergencyContacts();
    try {
      final eventId = await PanicAlertService().activatePanic(triggerSource: 'button');
      if (kDebugMode) print('✅ EmergencyPanicMode: eventId=$eventId');
      if (mounted) {
        setState(() {
          _emergencyContacts =
              _emergencyContacts.map((c) => {...c, 'notified': true}).toList();
        });
      }
      _showEmergencyToast('Modo de emergencia activado');
    } catch (e) {
      if (kDebugMode) print('❌ EmergencyPanicMode.activatePanic: $e');
      _showEmergencyToast('Error: $e');
    }
  }

  Future<void> _loadEmergencyContacts() async {
    try {
      final data = await SupabaseService.getEmergencyContacts();
      if (!mounted) return;
      setState(() {
        _emergencyContacts = data.map((c) => {
          'name': c['name'] as String,
          // Usa phone_wa si existe, cae en phone legacy como fallback
          'phone': (c['phone_wa'] ?? c['phone'] ?? '') as String,
          'notified': false,
        }).toList();
      });
    } catch (e) {
      if (kDebugMode) print('❌ Load emergency contacts error: $e');
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _triggerAutomaticEmergencyCall();
          timer.cancel();
        }
      });
    });
  }

  Future<void> _initializeLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showEmergencyToast('Servicio de ubicación desactivado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showEmergencyToast('Permiso de ubicación denegado');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showEmergencyToast('Permiso de ubicación denegado permanentemente');
        return;
      }

      // Get initial position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _accuracy = position.accuracy;
      });

      // Start continuous location tracking
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((Position position) {
            if (!mounted) return;

            setState(() {
              _latitude = position.latitude;
              _longitude = position.longitude;
              _accuracy = position.accuracy;
            });
          });
    } catch (e) {
      _showEmergencyToast('Error al obtener ubicación');
    }
  }

  Future<void> _startAudioRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/emergency_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);

        if (!mounted) return;

        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
          if (!mounted) return;

          setState(() {
            _recordingSeconds++;
            final minutes = _recordingSeconds ~/ 60;
            final seconds = _recordingSeconds % 60;
            _recordingDuration =
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
          });
        });
      }
    } catch (e) {
      _showEmergencyToast('Error al iniciar grabación');
    }
  }

  Future<void> _stopAudioRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();

      if (!mounted) return;

      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
        _recordingDuration = '00:00';
      });

      _showEmergencyToast('Grabación guardada');
    } catch (e) {
      _showEmergencyToast('Error al detener grabación');
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopAudioRecording();
    } else {
      await _startAudioRecording();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      if (!kIsWeb) {
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
        } catch (e) {}
      }
    } catch (e) {
      _showEmergencyToast('Error al inicializar cámara');
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        _showEmergencyToast('Foto capturada y guardada');
      }
    } catch (e) {
      _showEmergencyToast('Error al capturar foto');
    }
  }

  Future<void> _captureVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (video != null) {
        _showEmergencyToast('Video capturado y guardado');
      }
    } catch (e) {
      _showEmergencyToast('Error al capturar video');
    }
  }

  void _callEmergencyContact(String phoneNumber) {
    _showEmergencyToast('Llamando a $phoneNumber');
    // In production: launch phone dialer with url_launcher
  }

  void _callEmergencyService(String serviceName, String phoneNumber) {
    _showEmergencyToast('Llamando a $serviceName: $phoneNumber');
    // In production: launch phone dialer with url_launcher
  }

  void _triggerAutomaticEmergencyCall() {
    _showEmergencyToast('Notificando servicios de emergencia automáticamente');
    // In production: trigger automatic emergency service notification
  }

  void _showBackgroundNotification() {
    // In production: show persistent notification that emergency mode is active
  }

  void _showEmergencyToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
      fontSize: 14.sp,
    );
  }

  Future<void> _cancelEmergencyMode() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCancelConfirmationDialog(),
    );

    if (confirmed == true) {
      _countdownTimer?.cancel();
      _positionStream?.cancel();
      _recordingTimer?.cancel();
      if (_isRecording) {
        await _audioRecorder.stop();
      }
      _cameraController?.dispose();

      // Resuelve el panic_event y detiene el stream GPS
      await PanicAlertService().resolvePanic(resolution: 'false_alarm');

      if (!mounted) return;

      setState(() {
        _emergencyActive = false;
      });

      _showEmergencyToast('Modo de emergencia cancelado');

      if (!mounted) return;

      // Si la pantalla de pánico fue el punto de entrada (cold start desde servicio),
      // pop() no tiene nada a donde volver → ir al dashboard explícitamente.
      final nav = Navigator.of(context, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
      } else {
        nav.pushNamedAndRemoveUntil(AppRoutes.alertDashboard, (_) => false);
      }
    }
  }

  Widget _buildCancelConfirmationDialog() {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning_amber_rounded',
            color: theme.colorScheme.error,
            size: 24,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              '¿Cancelar Emergencia?',
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Text(
        '¿Estás seguro de que deseas cancelar el modo de emergencia? Se detendrán todas las notificaciones y grabaciones.',
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No, Continuar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text('Sí, Estoy Seguro'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _cancelEmergencyMode();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              EmergencyHeaderWidget(
                remainingSeconds: _remainingSeconds,
                isRecording: _isRecording,
                onCancelEmergency: _cancelEmergencyMode,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            _cancelEmergencyMode();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'check_circle',
                                color: Colors.white,
                                size: 32,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                'ESTOY SEGURO',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      LocationDisplayWidget(
                        latitude: _latitude,
                        longitude: _longitude,
                        accuracy: _accuracy,
                      ),
                      SizedBox(height: 2.h),
                      EmergencyContactsWidget(
                        contacts: _emergencyContacts,
                        onCallContact: _callEmergencyContact,
                      ),
                      SizedBox(height: 2.h),
                      EmergencyServicesWidget(
                        onCallService: _callEmergencyService,
                      ),
                      SizedBox(height: 2.h),
                      MediaCaptureWidget(
                        isRecording: _isRecording,
                        recordingDuration: _recordingDuration,
                        onToggleRecording: _toggleRecording,
                        onCapturePhoto: _capturePhoto,
                        onCaptureVideo: _captureVideo,
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'info_outline',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                'El modo de emergencia continuará funcionando en segundo plano',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
