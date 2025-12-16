import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/app_settings.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();   
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    
    if (settingsJson != null) {
      try {
        final settings = AppSettings.fromJson(
          Map<String, dynamic>.from(
            Uri.splitQueryString(settingsJson),
          ),
        );
        state = settings;
      } catch (e) {
        // Use default settings
      }
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = settings;
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', state.toJson().toString());
  }

  Future<void> updateEyeClosureThreshold(double threshold) async {
    state = state.copyWith(eyeClosureThreshold: threshold);
    await _saveSettings();
  }

  Future<void> updateAlertVolume(double volume) async {
    state = state.copyWith(alertVolume: volume);
    await _saveSettings();
  }

  Future<void> toggleVoiceAlerts(bool enabled) async {
    state = state.copyWith(enableVoiceAlerts: enabled);
    await _saveSettings();
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(enableVibration: enabled);
    await _saveSettings();
  }

  Future<void> toggleBatteryOptimization(bool enabled) async {
    state = state.copyWith(batteryOptimization: enabled);
    await _saveSettings();
  }

  Future<void> updateVoiceLanguage(String language) async {
    state = state.copyWith(voiceLanguage: language);
    await _saveSettings();
  }
}
