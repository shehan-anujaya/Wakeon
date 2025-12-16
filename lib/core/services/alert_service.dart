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
    await _flutterTts.setSpeechRate(0.4); // Slower for urgency
    await _flutterTts.setVolume(1.0); // Maximum volume
    await _flutterTts.setPitch(1.2); // Higher pitch for alarm effect
  }

  Future<void> triggerAlert({
    required AppSettings settings,
    required String message,
    bool isEmergency = false,
  }) async {
    if (_isAlertActive) return;
    
    _isAlertActive = true;

    try {
      // Vibrate device FIRST for immediate feedback
      if (settings.enableVibration) {
        await _vibrate(isEmergency);
      }

      // Voice alert - repeat 3 times for urgency
      if (settings.enableVoiceAlerts) {
        await _speakAlert('Alert! $message');
        await Future.delayed(const Duration(milliseconds: 500));
        await _speakAlert(message);
      }

      // Try alarm sound (will gracefully fail if file missing)
      await _playAlarmSound(settings.alertVolume);
    } catch (e) {
      debugPrint('Error triggering alert: $e');
    }
  }

  Future<void> _playAlarmSound(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // Try to play alarm sound from assets, fall back to beep pattern if not found
      try {
        await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
        debugPrint('✓ Alarm sound playing from assets');
      } catch (e) {
        debugPrint('⚠ Alarm sound file not found: $e');
        debugPrint('⚠ Using TTS and vibration for alerts');
        // Audio file doesn't exist, will rely on vibration and TTS
        // User should add alarm.mp3 to assets/sounds/ folder
      }
    } catch (e) {
      debugPrint('❌ Error playing alarm: $e');
    }
  }

  Future<void> _vibrate(bool isEmergency) async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == null || !hasVibrator) {
        debugPrint('⚠ No vibrator available');
        return;
      }

      if (isEmergency) {
        // Strong vibration pattern for emergency
        debugPrint('📳 Emergency vibration pattern');
        await Vibration.vibrate(
          pattern: [0, 500, 200, 500, 200, 500],
          intensities: [0, 255, 0, 255, 0, 255],
        );
      } else {
        // Regular vibration
        debugPrint('📳 Regular vibration');
        await Vibration.vibrate(duration: 1000);
      }
    } catch (e) {
      debugPrint('Error vibrating: $e');
    }
  }

  Future<void> _speakAlert(String message) async {
    try {
      debugPrint('🔊 Speaking alert: $message');
      await _flutterTts.speak(message);
    } catch (e) {
      debugPrint('❌ Error speaking alert: $e');
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
