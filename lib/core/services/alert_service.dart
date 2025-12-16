import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import '../models/app_settings.dart';

class AlertService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isAlertActive = false;
  
  bool get isAlertActive => _isAlertActive;

  Future<void> initialize(AppSettings settings) async {
    await _flutterTts.setLanguage(settings.voiceLanguage);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(settings.alertVolume);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> triggerAlert({
    required AppSettings settings,
    required String message,
    bool isEmergency = false,
  }) async {
    if (_isAlertActive) return;
    
    _isAlertActive = true;

    try {
      // Play alarm sound
      await _playAlarmSound(settings.alertVolume);

      // Vibrate device
      if (settings.enableVibration) {
        await _vibrate(isEmergency);
      }

      // Voice alert
      if (settings.enableVoiceAlerts) {
        await _speakAlert(message);
      }
    } catch (e) {
      debugPrint('Error triggering alert: $e');
    }
  }

  Future<void> _playAlarmSound(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Play alarm sound from assets
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      debugPrint('Error playing alarm: $e');
    }
  }

  Future<void> _vibrate(bool isEmergency) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == null || !hasVibrator) return;

      if (isEmergency) {
        // Strong vibration pattern for emergency
        await Vibration.vibrate(
          pattern: [0, 500, 200, 500, 200, 500],
          intensities: [0, 255, 0, 255, 0, 255],
        );
      } else {
        // Regular vibration
        await Vibration.vibrate(duration: 1000);
      }
    } catch (e) {
      debugPrint('Error vibrating: $e');
    }
  }

  Future<void> _speakAlert(String message) async {
    try {
      await _flutterTts.speak(message);
    } catch (e) {
      debugPrint('Error speaking alert: $e');
    }
  }

  Future<void> stopAlert() async {
    _isAlertActive = false;
    
    await _audioPlayer.stop();
    await _flutterTts.stop();
    await Vibration.cancel();
  }

  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
  }
}
