import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Detecta pulsaciones rápidas del botón de bloqueo mediante ciclos
/// AppLifecycleState.paused → resumed dentro de una ventana de tiempo.
///
/// Limitación de plataforma: Flutter no expone acceso directo al botón de bloqueo.
/// La detección funciona solo con la app en foreground.
/// En iOS el ciclo paused/resumed puede tener mayor latencia que en Android,
/// por lo que la ventana de tiempo puede ser insuficiente en algunos dispositivos Apple.
class PowerButtonDetectorService with WidgetsBindingObserver {
  static const Duration _tapWindow = Duration(milliseconds: 1500);
  static const Duration _minPauseDuration = Duration(milliseconds: 100);
  static const Duration _maxPauseDuration = Duration(milliseconds: 800);

  /// Número de pulsaciones requeridas (2 = doble, 3 = triple). Default: 3.
  final int requiredTaps;
  final VoidCallback onTrigger;

  int _tapCount = 0;
  DateTime? _lastPaused;
  Timer? _resetTimer;
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
    _resetTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_active) return;

    if (state == AppLifecycleState.paused) {
      _lastPaused = DateTime.now();
    }

    if (state == AppLifecycleState.resumed && _lastPaused != null) {
      final pauseDuration = DateTime.now().difference(_lastPaused!);

      // Solo contar si fue una pulsación corta (no bloqueo prolongado)
      if (pauseDuration >= _minPauseDuration &&
          pauseDuration <= _maxPauseDuration) {
        _tapCount++;
        _resetTimer?.cancel();

        if (kDebugMode) print('🔴 Power tap: $_tapCount/$requiredTaps');

        if (_tapCount >= requiredTaps) {
          _tapCount = 0;
          onTrigger();
        } else {
          Fluttertoast.showToast(
            msg:
                'Toque $_tapCount/$requiredTaps — sigue pulsando para activar pánico',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
          );
          // Resetear contador si no completa la secuencia en tiempo
          _resetTimer = Timer(_tapWindow, () => _tapCount = 0);
        }
      }
      _lastPaused = null;
    }
  }

  void dispose() {
    stop();
    _resetTimer?.cancel();
  }
}
