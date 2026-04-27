import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Detecta pulsaciones del botón de bloqueo contando eventos AppLifecycleState.paused.
///
/// Flujo: cada vez que el usuario apaga la pantalla = 1 tap.
/// Al completar [requiredTaps] pulsaciones dentro de [_tapWindow],
/// el trigger se ejecuta en el siguiente AppLifecycleState.resumed
/// (cuando la pantalla vuelve a encenderse) para garantizar que la
/// navegación ocurra con la app en primer plano.
///
/// Limitación de plataforma: solo funciona con la app en foreground.
class PowerButtonDetectorService with WidgetsBindingObserver {
  static const Duration _tapWindow = Duration(seconds: 3);

  final int requiredTaps;
  final VoidCallback onTrigger;

  int _tapCount = 0;
  Timer? _resetTimer;
  bool _triggerPending = false;
  bool _active = false;

  PowerButtonDetectorService({
    required this.onTrigger,
    this.requiredTaps = 3,
  });

  void start() {
    if (_active) return;
    _active = true;
    WidgetsBinding.instance.addObserver(this);
  }

  void stop() {
    _active = false;
    _tapCount = 0;
    _triggerPending = false;
    _resetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active) return;

    if (state == AppLifecycleState.paused) {
      _tapCount++;
      _resetTimer?.cancel();

      if (kDebugMode) print('🔴 Power press: $_tapCount/$requiredTaps');

      if (_tapCount >= requiredTaps) {
        _tapCount = 0;
        _triggerPending = true;
        // El trigger se ejecuta en el siguiente resumed para que
        // la navegación ocurra con la app activa.
      } else {
        // Reinicia el contador si no llegan más pulsaciones en la ventana
        _resetTimer = Timer(_tapWindow, () {
          if (kDebugMode) print('🔴 Power tap reset (timeout)');
          _tapCount = 0;
        });
      }
    }

    if (state == AppLifecycleState.resumed) {
      if (_triggerPending) {
        _triggerPending = false;
        onTrigger();
      } else if (_tapCount > 0) {
        // Muestra progreso cuando el usuario vuelve a encender la pantalla
        final remaining = requiredTaps - _tapCount;
        Fluttertoast.showToast(
          msg: '🚨 SOS: $_tapCount/$requiredTaps — pulsa $remaining ${remaining == 1 ? 'vez' : 'veces'} más',
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
