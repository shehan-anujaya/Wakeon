import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final double eyeClosureThreshold;
  final double alertVolume;
  final bool enableVoiceAlerts;
  final bool enableVibration;
  final bool enableFlashScreen;
  final bool batteryOptimization;
  final String voiceLanguage;
  final bool enableLocationSharing;
  final int alertEscalationTime;

  const AppSettings({
    this.eyeClosureThreshold = 2.5,
    this.alertVolume = 0.8,
    this.enableVoiceAlerts = true,
    this.enableVibration = true,
    this.enableFlashScreen = true,
    this.batteryOptimization = false,
    this.voiceLanguage = 'en-US',
    this.enableLocationSharing = true,
    this.alertEscalationTime = 10,
  });

  AppSettings copyWith({
    double? eyeClosureThreshold,
    double? alertVolume,
    bool? enableVoiceAlerts,
    bool? enableVibration,
    bool? enableFlashScreen,
    bool? batteryOptimization,
    String? voiceLanguage,
    bool? enableLocationSharing,
    int? alertEscalationTime,
  }) {
    return AppSettings(
      eyeClosureThreshold: eyeClosureThreshold ?? this.eyeClosureThreshold,
      alertVolume: alertVolume ?? this.alertVolume,
      enableVoiceAlerts: enableVoiceAlerts ?? this.enableVoiceAlerts,
      enableVibration: enableVibration ?? this.enableVibration,
      enableFlashScreen: enableFlashScreen ?? this.enableFlashScreen,
      batteryOptimization: batteryOptimization ?? this.batteryOptimization,
      voiceLanguage: voiceLanguage ?? this.voiceLanguage,
      enableLocationSharing: enableLocationSharing ?? this.enableLocationSharing,
      alertEscalationTime: alertEscalationTime ?? this.alertEscalationTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eyeClosureThreshold': eyeClosureThreshold,
      'alertVolume': alertVolume,
      'enableVoiceAlerts': enableVoiceAlerts,
      'enableVibration': enableVibration,
      'enableFlashScreen': enableFlashScreen,
      'batteryOptimization': batteryOptimization,
      'voiceLanguage': voiceLanguage,
      'enableLocationSharing': enableLocationSharing,
      'alertEscalationTime': alertEscalationTime,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      eyeClosureThreshold: json['eyeClosureThreshold'] ?? 2.5,
      alertVolume: json['alertVolume'] ?? 0.8,
      enableVoiceAlerts: json['enableVoiceAlerts'] ?? true,
      enableVibration: json['enableVibration'] ?? true,
      enableFlashScreen: json['enableFlashScreen'] ?? true,
      batteryOptimization: json['batteryOptimization'] ?? false,
      voiceLanguage: json['voiceLanguage'] ?? 'en-US',
      enableLocationSharing: json['enableLocationSharing'] ?? true,
      alertEscalationTime: json['alertEscalationTime'] ?? 10,
    );
  }

  @override
  List<Object?> get props => [
        eyeClosureThreshold,
        alertVolume,
        enableVoiceAlerts,
        enableVibration,
        enableFlashScreen,
        batteryOptimization,
        voiceLanguage,
        enableLocationSharing,
        alertEscalationTime,
      ];
}
