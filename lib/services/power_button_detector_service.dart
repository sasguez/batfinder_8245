import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Detecta pulsaciones del botón de encendido escuchando eventos nativos
/// de Android (ACTION_SCREEN_OFF / ACTION_SCREEN_ON) via EventChannel.
///
/// Flujo con requiredTaps = 3:
///   Apaga pantalla (1) → enciende → toast "1/3"
///   Apaga pantalla (2) → enciende → toast "2/3"
///   Apaga pantalla (3) → enciende → PÁNICO ACTIVADO
///
/// Ventaja sobre el lifecycle: funciona aunque el dispositivo tenga
/// pantalla de bloqueo, ya que el BroadcastReceiver nativo recibe
/// SCREEN_OFF sin necesitar que el usuario desbloquee.
class PowerButtonDetectorService {
  static const EventChannel _screenChannel =
      EventChannel('com.batfinder.android/screen_events');
  static const Duration _tapWindow = Duration(seconds: 5);

  final int requiredTaps;
  final VoidCallback onTrigger;

  int _tapCount = 0;
  bool _triggerPending = false;
  Timer? _resetTimer;
  StreamSubscription<dynamic>? _subscription;
  bool _active = false;

  PowerButtonDetectorService({
    required this.onTrigger,
    this.requiredTaps = 3,
  });

  void start() {
    if (_active) return;
    _active = true;
    _subscription = _screenChannel
        .receiveBroadcastStream()
        .listen(_onScreenEvent, onError: (_) {});
  }

  void stop() {
    _active = false;
    _tapCount = 0;
    _triggerPending = false;
    _resetTimer?.cancel();
    _subscription?.cancel();
    _subscription = null;
  }

  void _onScreenEvent(dynamic event) {
    if (!_active) return;

    if (event == 'screen_off') {
      _tapCount++;
      _resetTimer?.cancel();

      if (kDebugMode) print('🔴 Power press: $_tapCount/$requiredTaps');

      if (_tapCount >= requiredTaps) {
        _tapCount = 0;
        _triggerPending = true;
        // Dispara en el próximo screen_on para que la navegación
        // ocurra con la pantalla activa.
      } else {
        _resetTimer = Timer(_tapWindow, () {
          if (kDebugMode) print('🔴 Power tap reset (timeout)');
          _tapCount = 0;
        });
      }
    }

    if (event == 'screen_on') {
      if (_triggerPending) {
        _triggerPending = false;
        onTrigger();
      } else if (_tapCount > 0) {
        final remaining = requiredTaps - _tapCount;
        Fluttertoast.showToast(
          msg: '🚨 SOS: $_tapCount/$requiredTaps'
              ' — apaga la pantalla $remaining'
              ' ${remaining == 1 ? 'vez' : 'veces'} más',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
          fontSize: 14,
        );
      }
    }
  }

  void dispose() => stop();
}
