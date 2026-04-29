import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VibrationService {
  static final VibrationService _instance = VibrationService._internal();
  factory VibrationService() => _instance;
  VibrationService._internal();

  Future<bool> _isVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notif_vibration') ?? true;
  }

  Future<void> vibrateAlert() async {
    if (!await _isVibrationEnabled()) return;
    await _vibrate();
  }

  Future<void> testVibration() async {
    await _vibrate();
  }

  // Patrón de 3 pulsos cortos para diferenciar de un haptic de UI normal
  Future<void> _vibrate() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }
}
