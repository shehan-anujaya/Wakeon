import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/driving_session.dart';
import '../../../core/models/drowsiness_event.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/drowsiness_detection_service.dart';
import '../../../core/services/alert_service.dart';
import '../../../core/services/location_service.dart';
import '../../settings/providers/settings_provider.dart';
import '../../emergency_contacts/providers/emergency_contacts_provider.dart';

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final detectionServiceProvider = Provider<DrowsinessDetectionService>((ref) {
  return DrowsinessDetectionService();
});

final alertServiceProvider = Provider<AlertService>((ref) {
  return AlertService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final drivingSessionProvider = StateNotifierProvider<DrivingSessionNotifier, DrivingSession?>((ref) {
  return DrivingSessionNotifier(ref);
});

class DrivingSessionNotifier extends StateNotifier<DrivingSession?> {
  final Ref _ref;
  Timer? _alertEscalationTimer;

  DrivingSessionNotifier(this._ref) : super(null);

  Future<void> startSession() async {
    final newSession = DrivingSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
    );
    
    state = newSession;

    // Initialize camera
    final cameraService = _ref.read(cameraServiceProvider);
    await cameraService.initialize();

    // Start detection
    await cameraService.startImageStream(_processImage);
  }

  Future<void> endSession() async {
    if (state == null) return;

    final duration = DateTime.now().difference(state!.startTime);
    state = state!.copyWith(
      endTime: DateTime.now(),
      duration: duration,
    );

    // Stop camera
    final cameraService = _ref.read(cameraServiceProvider);
    await cameraService.dispose();

    // Cancel any pending alerts
    _alertEscalationTimer?.cancel();
  }

  Future<void> _processImage(CameraImage image) async {
    if (state == null) return;

    final detectionService = _ref.read(detectionServiceProvider);
    final settings = _ref.read(settingsProvider);

    detectionService.updateThreshold(settings.eyeClosureThreshold);

    final result = await detectionService.processImage(image);
    
    if (result == null) return;

    // Update current detection status in real-time
    state = state!.copyWith(
      currentDetectionStatus: result.status,
      currentStatusMessage: result.message,
      faceLockedIn: result.faceDetected == true && result.message == 'Driver alert',
    );

    if (result.status == DetectionStatus.drowsy) {
      await _handleDrowsinessDetected(result);
    } else if (result.status == DetectionStatus.slight) {
      // Show warning but don't trigger full alert
    }
  }

  Future<void> _handleDrowsinessDetected(DetectionResult result) async {
    final alertService = _ref.read(alertServiceProvider);
    final settings = _ref.read(settingsProvider);

    // Create drowsiness event
    final event = DrowsinessEvent(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      sessionId: state!.id,
      eyeClosureDuration: result.eyeClosureDuration!,
      level: result.level!,
      alertTriggered: true,
    );

    // Update session
    state = state!.copyWith(
      drowsinessEventsCount: state!.drowsinessEventsCount + 1,
      eventIds: [...state!.eventIds, event.id],
    );

    // Trigger alert with more urgent message
    await alertService.triggerAlert(
      settings: settings,
      message: 'Wake up! Wake up! Stay alert! You are getting drowsy!',
    );

    // Start escalation timer
    _startAlertEscalation(event);
  }

  void _startAlertEscalation(DrowsinessEvent event) {
    final settings = _ref.read(settingsProvider);
    
    _alertEscalationTimer?.cancel();
    _alertEscalationTimer = Timer(
      Duration(seconds: settings.alertEscalationTime),
      () => _escalateToEmergency(event),
    );
  }

  Future<void> _escalateToEmergency(DrowsinessEvent event) async {
    final emergencyService = _ref.read(emergencyServiceProvider);
    final locationService = _ref.read(locationServiceProvider);
    final contacts = _ref.read(emergencyContactsProvider);
    final settings = _ref.read(settingsProvider);

    if (contacts.isEmpty) return;

    // Get location if enabled
    String location = 'Location unavailable';
    if (settings.enableLocationSharing) {
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        location = locationService.getGoogleMapsUrl(position);
      }
    }

    // Trigger emergency
    await emergencyService.triggerEmergency(
      contacts: contacts,
      location: location,
    );

    // Update session
    state = state!.copyWith(emergencyTriggered: true);
  }

  void dismissAlert() {
    _alertEscalationTimer?.cancel();
    
    final alertService = _ref.read(alertServiceProvider);
    alertService.stopAlert();
  }

  // DEBUG: Simulate drowsiness detection
  Future<void> debugTriggerDrowsiness() async {
    if (state == null) return;

    // Update visual status to drowsy
    state = state!.copyWith(
      currentDetectionStatus: DetectionStatus.drowsy,
      currentStatusMessage: 'DROWSINESS DETECTED',
    );

    // Create a mock drowsiness result
    final mockResult = DetectionResult(
      status: DetectionStatus.drowsy,
      message: 'DROWSINESS DETECTED',
      eyeClosureDuration: 3.0,
      level: DrowsinessLevel.severe,
    );

    // Trigger the full alert system
    await _handleDrowsinessDetected(mockResult);
  }

  // DEBUG: Simulate slight fatigue
  void debugTriggerFatigue() {
    if (state == null) return;

    state = state!.copyWith(
      currentDetectionStatus: DetectionStatus.slight,
      currentStatusMessage: 'SLIGHT FATIGUE',
    );
  }

  // DEBUG: Reset to alert state
  void debugResetState() {
    if (state == null) return;

    state = state!.copyWith(
      currentDetectionStatus: DetectionStatus.alert,
      currentStatusMessage: 'ALERT',
    );

    dismissAlert();
  }
}
