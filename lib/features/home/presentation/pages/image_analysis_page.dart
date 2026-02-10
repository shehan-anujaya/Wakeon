import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/drowsiness_detection_service.dart';

/// Page for analyzing drowsiness from uploaded images
class ImageAnalysisPage extends StatefulWidget {
  const ImageAnalysisPage({super.key});

  @override
  State<ImageAnalysisPage> createState() => _ImageAnalysisPageState();
}

class _ImageAnalysisPageState extends State<ImageAnalysisPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableTracking: false,
      minFaceSize: 0.15,
    ),
  );

  File? _selectedImage;
  bool _isAnalyzing = false;
  ImageAnalysisResult? _analysisResult;

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _analysisResult = null;
        });
        await _analyzeImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAnalyzing = true;
      _analysisResult = null;
    });

    try {
      final inputImage = InputImage.fromFilePath(_selectedImage!.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        setState(() {
          _analysisResult = ImageAnalysisResult(
            status: DetectionStatus.alert,
            message: 'No face detected in the image',
            faceDetected: false,
          );
        });
      } else {
        final face = faces.first;
        
        // Get eye probabilities
        final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
        final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
        final avgEyeOpen = (leftEyeOpen + rightEyeOpen) / 2;
        
        // Get head pose
        final headPitch = face.headEulerAngleX ?? 0.0;
        final headYaw = face.headEulerAngleY ?? 0.0;
        final headRoll = face.headEulerAngleZ ?? 0.0;
        
        // Determine drowsiness status
        DetectionStatus status;
        String message;
        String details;
        
        if (avgEyeOpen < 0.3) {
          status = DetectionStatus.drowsy;
          message = 'DROWSINESS DETECTED';
          details = 'Eyes appear to be closed or nearly closed. This indicates potential drowsiness or fatigue.';
        } else if (avgEyeOpen < 0.5 || headPitch > 15.0) {
          status = DetectionStatus.slight;
          message = 'FATIGUE WARNING';
          if (headPitch > 15.0) {
            details = 'Head is tilted downward, which may indicate fatigue or distraction.';
          } else {
            details = 'Eyes are partially closed, showing early signs of drowsiness.';
          }
        } else {
          status = DetectionStatus.alert;
          message = 'ALERT STATUS';
          details = 'Eyes are open and face position is normal. No signs of drowsiness detected.';
        }
        
        setState(() {
          _analysisResult = ImageAnalysisResult(
            status: status,
            message: message,
            details: details,
            faceDetected: true,
            leftEyeOpen: leftEyeOpen,
            rightEyeOpen: rightEyeOpen,
            headPitch: headPitch,
            headYaw: headYaw,
            headRoll: headRoll,
            faceCount: faces.length,
          );
        });
      }
    } catch (e) {
      _showError('Analysis failed: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.neonRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Image Analysis',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 24),
            _buildUploadButtons(),
            const SizedBox(height: 24),
            if (_isAnalyzing) _buildLoadingIndicator(),
            if (_analysisResult != null) _buildAnalysisResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedImage != null
              ? AppTheme.neonBlue.withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: _selectedImage != null
            ? [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _selectedImage != null
            ? Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Upload an image to analyze',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Face must be clearly visible',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildUploadButton(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            color: AppTheme.neonBlue,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildUploadButton(
            icon: Icons.camera_alt_outlined,
            label: 'Camera',
            color: AppTheme.neonAmber,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: _isAnalyzing ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing image...',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detecting face and analyzing drowsiness indicators',
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResult() {
    final result = _analysisResult!;
    
    Color statusColor;
    IconData statusIcon;
    
    switch (result.status) {
      case DetectionStatus.alert:
        statusColor = AppTheme.neonGreen;
        statusIcon = Icons.check_circle_rounded;
        break;
      case DetectionStatus.slight:
        statusColor = AppTheme.neonAmber;
        statusIcon = Icons.warning_rounded;
        break;
      case DetectionStatus.drowsy:
        statusColor = AppTheme.neonRed;
        statusIcon = Icons.error_rounded;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            result.message,
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: statusColor,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          if (result.details != null) ...[
            const SizedBox(height: 12),
            Text(
              result.details!,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // Metrics
          if (result.faceDetected) ...[
            const SizedBox(height: 24),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Text(
              'DETECTION METRICS',
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Left Eye Open',
              '${((result.leftEyeOpen ?? 0) * 100).toStringAsFixed(0)}%',
              result.leftEyeOpen ?? 0,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Right Eye Open',
              '${((result.rightEyeOpen ?? 0) * 100).toStringAsFixed(0)}%',
              result.rightEyeOpen ?? 0,
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Head Pitch',
              '${(result.headPitch ?? 0).toStringAsFixed(1)}°',
              1 - ((result.headPitch ?? 0).abs() / 45).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 12),
            _buildMetricRow(
              'Head Yaw',
              '${(result.headYaw ?? 0).toStringAsFixed(1)}°',
              1 - ((result.headYaw ?? 0).abs() / 45).clamp(0.0, 1.0),
            ),
            if ((result.faceCount ?? 1) > 1) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.neonAmber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${result.faceCount} faces detected. Analyzing primary face.',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppTheme.neonAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          
          // No face message
          if (!result.faceDetected) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.face_retouching_off,
                    color: Colors.white.withOpacity(0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please upload an image with a clearly visible face looking towards the camera.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress) {
    Color progressColor;
    if (progress > 0.7) {
      progressColor = AppTheme.neonGreen;
    } else if (progress > 0.4) {
      progressColor = AppTheme.neonAmber;
    } else {
      progressColor = AppTheme.neonRed;
    }
    
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 50,
          child: Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: progressColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

/// Result model for image analysis
class ImageAnalysisResult {
  final DetectionStatus status;
  final String message;
  final String? details;
  final bool faceDetected;
  final double? leftEyeOpen;
  final double? rightEyeOpen;
  final double? headPitch;
  final double? headYaw;
  final double? headRoll;
  final int? faceCount;

  ImageAnalysisResult({
    required this.status,
    required this.message,
    this.details,
    required this.faceDetected,
    this.leftEyeOpen,
    this.rightEyeOpen,
    this.headPitch,
    this.headYaw,
    this.headRoll,
    this.faceCount,
  });
}
