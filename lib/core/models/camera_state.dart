import 'package:camera/camera.dart';

class CameraState {
  final bool isInitialized;
  final String? error;
  final CameraController? controller;

  CameraState({
    required this.isInitialized,
    this.error,
    this.controller,
  });

  factory CameraState.initial() {
    return CameraState(isInitialized: false);
  }

  factory CameraState.initialized(CameraController controller) {
    return CameraState(
      isInitialized: true,
      controller: controller,
    );
  }

  factory CameraState.error(String error) {
    return CameraState(
      isInitialized: false,
      error: error,
    );
  }
}
