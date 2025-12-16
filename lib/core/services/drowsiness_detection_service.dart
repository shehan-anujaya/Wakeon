import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:typed_data';
import '../models/drowsiness_event.dart';

enum DetectionStatus {
  alert,
  slight,
  drowsy,
}

class DrowsinessDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );

  DateTime? _eyesClosedStartTime;
  DateTime? _headDownStartTime;
  int _blinkCount = 0;
  DateTime _lastBlinkResetTime = DateTime.now();
  
  double _eyeClosureThreshold = 2.5; // seconds
  double _headDownThreshold = 1.5; // seconds for head down detection
  bool _isProcessing = false;
  bool _faceLockedIn = false;

  void updateThreshold(double threshold) {
    _eyeClosureThreshold = threshold;
  }

  Future<DetectionResult?> processImage(CameraImage image) async {
    if (_isProcessing) return null;
    
    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return null;
      }

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        _resetDetection();
        _faceLockedIn = false;
        _isProcessing = false;
        return DetectionResult(
          status: DetectionStatus.alert,
          message: 'No face detected',
          faceDetected: false,
        );
      }

      final face = faces.first;
      
      // Check if face is properly positioned (center of frame)
      final faceRect = face.boundingBox;
      final imageCenterX = inputImage.metadata!.size.width / 2;
      final imageCenterY = inputImage.metadata!.size.height / 2;
      final faceCenterX = faceRect.left + (faceRect.width / 2);
      final faceCenterY = faceRect.top + (faceRect.height / 2);
      
      final xOffset = (faceCenterX - imageCenterX).abs();
      final yOffset = (faceCenterY - imageCenterY).abs();
      
      // Face is well positioned if within 30% of center
      final isWellPositioned = xOffset < inputImage.metadata!.size.width * 0.3 && 
                               yOffset < inputImage.metadata!.size.height * 0.3 &&
                               faceRect.width > 100; // Minimum face size
      
      if (!_faceLockedIn && isWellPositioned) {
        _faceLockedIn = true;
      }
      
      // Get head pose angles
      final headEulerAngleX = face.headEulerAngleX ?? 0.0; // Pitch (up/down)
      final headEulerAngleY = face.headEulerAngleY ?? 0.0; // Yaw (left/right)
      final headEulerAngleZ = face.headEulerAngleZ ?? 0.0; // Roll (tilt)
      
      // Detect head down: pitch angle > 15 degrees means head is tilted down
      final isHeadDown = headEulerAngleX > 15.0;
      
      // Check for head down drowsiness (more reliable than eye closure)
      if (_faceLockedIn && isHeadDown) {
        _headDownStartTime ??= DateTime.now();
        
        final headDownDuration = DateTime.now().difference(_headDownStartTime!);
        
        if (headDownDuration.inMilliseconds > _headDownThreshold * 1000) {
          _isProcessing = false;
          return DetectionResult(
            status: DetectionStatus.drowsy,
            message: 'Head down detected!',
            eyeClosureDuration: headDownDuration.inMilliseconds / 1000,
            level: DrowsinessLevel.severe,
            faceDetected: true,
            headPose: HeadPose(
              pitch: headEulerAngleX,
              yaw: headEulerAngleY,
              roll: headEulerAngleZ,
            ),
          );
        } else if (headDownDuration.inMilliseconds > 800) {
          _isProcessing = false;
          return DetectionResult(
            status: DetectionStatus.slight,
            message: 'Head tilting down...',
            eyeClosureDuration: headDownDuration.inMilliseconds / 1000,
            faceDetected: true,
            headPose: HeadPose(
              pitch: headEulerAngleX,
              yaw: headEulerAngleY,
              roll: headEulerAngleZ,
            ),
          );
        }
      } else {
        _headDownStartTime = null;
      }
      
      // Check eye states
      final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
      
      final eyesOpen = (leftEyeOpen + rightEyeOpen) / 2 > 0.5;

      if (!eyesOpen) {
        _eyesClosedStartTime ??= DateTime.now();
        
        final closureDuration = DateTime.now().difference(_eyesClosedStartTime!);
        
        if (closureDuration.inMilliseconds > _eyeClosureThreshold * 1000) {
          _isProcessing = false;
          return DetectionResult(
            status: DetectionStatus.drowsy,
            message: 'Drowsiness detected!',
            eyeClosureDuration: closureDuration.inMilliseconds / 1000,
            level: _getDrowsinessLevel(closureDuration.inMilliseconds / 1000),
          );
        } else if (closureDuration.inMilliseconds > 1000) {
          _isProcessing = false;
          return DetectionResult(
            status: DetectionStatus.slight,
            message: 'Eyes closing...',
            eyeClosureDuration: closureDuration.inMilliseconds / 1000,
          );
        }
      } else {
        if (_eyesClosedStartTime != null) {
          _blinkCount++;
          _eyesClosedStartTime = null;
        }
      }

      // Reset blink count every 10 seconds
      if (DateTime.now().difference(_lastBlinkResetTime).inSeconds > 10) {
        _blinkCount = 0;
        _lastBlinkResetTime = DateTime.now();
      }

      _isProcessing = false;
      return DetectionResult(
        status: DetectionStatus.alert,
        message: _faceLockedIn ? 'Driver alert' : 'Position your face',
        blinkCount: _blinkCount,
        faceDetected: true,
        headPose: HeadPose(
          pitch: headEulerAngleX,
          yaw: headEulerAngleY,
          roll: headEulerAngleZ,
        ),
      );
      
    } catch (e) {
      debugPrint('Error processing image: $e');
      _isProcessing = false;
      return null;
    }
  }

  DrowsinessLevel _getDrowsinessLevel(double duration) {
    if (duration > 4) return DrowsinessLevel.severe;
    if (duration > 3) return DrowsinessLevel.moderate;
    return DrowsinessLevel.slight;
  }

  InputImage? _convertToInputImage(CameraImage image) {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (final Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final imageRotation = InputImageRotation.rotation0deg;

      final inputImageFormat = InputImageFormat.yuv420;

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: imageRotation,
        format: inputImageFormat,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      debugPrint('Error converting image: $e');
      return null;
    }
  }

  void _resetDetection() {
    _eyesClosedStartTime = null;
    _headDownStartTime = null;
  }

  void dispose() {
    _faceDetector.close();
  }
}

class HeadPose {
  final double pitch; // Up/down tilt
  final double yaw;   // Left/right turn
  final double roll;  // Side tilt

  HeadPose({
    required this.pitch,
    required this.yaw,
    required this.roll,
  });
}

class DetectionResult {
  final DetectionStatus status;
  final String message;
  final double? eyeClosureDuration;
  final DrowsinessLevel? level;
  final int? blinkCount;
  final bool? faceDetected;
  final HeadPose? headPose;

  DetectionResult({
    required this.status,
    required this.message,
    this.eyeClosureDuration,
    this.level,
    this.blinkCount,
    this.faceDetected,
    this.headPose,
  });
}
