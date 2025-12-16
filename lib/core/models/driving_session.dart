import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../services/drowsiness_detection_service.dart';

part 'driving_session.g.dart';

@HiveType(typeId: 0)
class DrivingSession extends Equatable {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime startTime;
  
  @HiveField(2)
  final DateTime? endTime;
  
  @HiveField(3)
  final int drowsinessEventsCount;
  
  @HiveField(4)
  final Duration duration;
  
  @HiveField(5)
  final List<String> eventIds;
  
  @HiveField(6)
  final bool emergencyTriggered;
  
  // Not persisted - only for UI state
  final DetectionStatus? currentDetectionStatus;
  final String? currentStatusMessage;

  const DrivingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.drowsinessEventsCount = 0,
    this.duration = Duration.zero,
    this.eventIds = const [],
    this.emergencyTriggered = false,
    this.currentDetectionStatus,
    this.currentStatusMessage,
  });

  DrivingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? drowsinessEventsCount,
    Duration? duration,
    List<String>? eventIds,
    bool? emergencyTriggered,
    DetectionStatus? currentDetectionStatus,
    String? currentStatusMessage,
  }) {
    return DrivingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      drowsinessEventsCount: drowsinessEventsCount ?? this.drowsinessEventsCount,
      duration: duration ?? this.duration,
      eventIds: eventIds ?? this.eventIds,
      emergencyTriggered: emergencyTriggered ?? this.emergencyTriggered,
      currentDetectionStatus: currentDetectionStatus ?? this.currentDetectionStatus,
      currentStatusMessage: currentStatusMessage ?? this.currentStatusMessage,
    );
  }

  bool get isActive => endTime == null;

  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  @override
  List<Object?> get props => [
        id,
        startTime,
        endTime,
        drowsinessEventsCount,
        duration,
        eventIds,
        emergencyTriggered,
        currentDetectionStatus,
        currentStatusMessage,
      ];
}
