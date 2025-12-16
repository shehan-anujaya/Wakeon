import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import '../models/camera_state.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<CameraState> initialize() async {
    try {
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        return CameraState.error('No cameras found on device');
      }

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      
      return CameraState.initialized(_controller!);
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return CameraState.error('Failed to initialize camera: ${e.toString()}');
    }
  }

  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }

    if (_controller!.value.isStreamingImages) {
      return;
    }

    await _controller!.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller!.stopImageStream();
    }
  }

  Future<void> dispose() async {
    await stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void toggleFlash() async {
    if (_controller == null) return;
    
    final currentMode = _controller!.value.flashMode;
    final newMode = currentMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    
    await _controller!.setFlashMode(newMode);
  }
}
