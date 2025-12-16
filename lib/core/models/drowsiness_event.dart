import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'drowsiness_event.g.dart';

enum DrowsinessLevel {
  slight,
  moderate,
  severe,
}

@HiveType(typeId: 1)
class DrowsinessEvent extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime timestamp;
  
  @HiveField(2)
  final String sessionId;
  
  @HiveField(3)
  final double eyeClosureDuration;
  
  @HiveField(4)
  final DrowsinessLevel level;
  
  @HiveField(5)
  final bool alertTriggered;
  
  @HiveField(6)
  final bool userResponded;
  
  @HiveField(7)
  final String? location;

  const DrowsinessEvent({
    required this.id,
    required this.timestamp,
    required this.sessionId,
    required this.eyeClosureDuration,
    required this.level,
    this.alertTriggered = false,
    this.userResponded = false,
    this.location,
  });

  DrowsinessEvent copyWith({
    String? id,
    DateTime? timestamp,
    String? sessionId,
    double? eyeClosureDuration,
    DrowsinessLevel? level,
    bool? alertTriggered,
    bool? userResponded,
    String? location,
  }) {
    return DrowsinessEvent(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      eyeClosureDuration: eyeClosureDuration ?? this.eyeClosureDuration,
      level: level ?? this.level,
      alertTriggered: alertTriggered ?? this.alertTriggered,
      userResponded: userResponded ?? this.userResponded,
      location: location ?? this.location,
    );
  }

  String get levelText {
    switch (level) {
      case DrowsinessLevel.slight:
        return 'Slight Fatigue';
      case DrowsinessLevel.moderate:
        return 'Moderate Drowsiness';
      case DrowsinessLevel.severe:
        return 'Severe Drowsiness';
    }
  }

  @override
  List<Object?> get props => [
        id,
        timestamp,
        sessionId,
        eyeClosureDuration,
        level,
        alertTriggered,
        userResponded,
        location,
      ];
}

@HiveType(typeId: 10)
enum DrowsinessLevelAdapter {
  @HiveField(0)
  slight,
  @HiveField(1)
  moderate,
  @HiveField(2)
  severe,
}
