import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  static const String _alertAsset = 'batfinder_alert.mp3';

  Future<bool> _isSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notif_sound') ?? true;
  }

  Future<void> playAlertSound() async {
    if (!await _isSoundEnabled()) return;
    await _play();
  }

  Future<void> playTestSound() async {
    await _play();
  }

  Future<void> _play() async {
    // Crea un player fresco por reproducción para evitar problemas de estado
    final player = AudioPlayer();
    try {
      await player.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          // Usa el stream de notificaciones (respeta volumen de ring/notif)
          usageType: AndroidUsageType.notificationRingtone,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
        ),
      ));
      await player.play(AssetSource(_alertAsset));
      // Limpia el player cuando termina la reproducción
      player.onPlayerComplete.listen((_) => player.dispose());
    } catch (e) {
      if (kDebugMode) print('❌ SoundService._play error: $e');
      await player.dispose();
    }
  }
}
