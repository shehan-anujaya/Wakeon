import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/driving_session_provider.dart';
import '../../../emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/services/drowsiness_detection_service.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DrivingScreen(),
    const EmergencyContactsPage(),
    const AnalyticsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppTheme.borderColor.withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: AppTheme.neonGreen,
                unselectedItemColor: AppTheme.textTertiary,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                items: [
                  _buildNavItem(Icons.speed_rounded, Icons.speed_rounded, 'Drive'),
                  _buildNavItem(Icons.emergency_outlined, Icons.emergency, 'Contacts'),
                  _buildNavItem(Icons.analytics_outlined, Icons.analytics, 'Analytics'),
                  _buildNavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Icon(icon, size: 24),
      ),
      activeIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.neonGreen.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(activeIcon, size: 24),
      ),
      label: label,
    );
  }
}

class DrivingScreen extends ConsumerStatefulWidget {
  const DrivingScreen({super.key});

  @override
  ConsumerState<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends ConsumerState<DrivingScreen> {
  DetectionStatus _currentStatus = DetectionStatus.alert;
  String _statusMessage = 'SYSTEM READY';
  bool _isDriving = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(drivingSessionProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundBlack,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WAKEON',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'ACTIVE MONITORING',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.neonGreen,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.battery_full, size: 16, color: AppTheme.neonGreen),
                        const SizedBox(width: 8),
                        Text(
                          '100%',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Main Dashboard Circle
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor().withOpacity(0.15),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress/Status Ring
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor().withOpacity(0.3)),
                    ),
                  ),
                  
                  // Inner Camera/Status Container
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceDark,
                      border: Border.all(
                        color: _getStatusColor().withOpacity(0.5),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _isDriving 
                        ? _buildCameraPreview() 
                        : _buildReadyState(),
                    ),
                  ),
                  
                  // Status Icon Badge
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(),
                            color: _getStatusColor(),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _getStatusText(),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Session Stats or Start Button
            if (_isDriving && session != null)
              _buildSessionInfo(session)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: _buildStartButton(),
              ),

            // Spacing for bottom nav (standard height is ~56-80, using 140 to be safe for bubble pill)
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cameraService = ref.read(cameraServiceProvider);
    
    if (cameraService.controller == null || !cameraService.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      );
    }

    return CameraPreview(cameraService.controller!);
  }

  Widget _buildReadyState() {
    return Container(
      color: const Color(0xFF131315),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.speed,
            size: 64,
            color: AppTheme.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'SYSTEM OFF',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textTertiary,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startDriving,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.neonGreen,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_filled_rounded, color: Colors.black, size: 32),
            const SizedBox(width: 16),
            Text(
              'START DRIVING',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(session) {
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem('DURATION', hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m', Icons.timer),
            _buildStatItem('ALERTS', '${session.drowsinessEventsCount}', Icons.warning_amber),
          ],
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: _stopDriving,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 50),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonRed.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stop_circle_outlined, color: AppTheme.neonRed),
                const SizedBox(width: 12),
                Text(
                  'STOP DRIVING',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonRed,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Icon(icon, color: AppTheme.textSecondary, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  void _startDriving() async {
    setState(() {
      _isDriving = true;
      _statusMessage = 'INITIALIZING...';
    });

    await ref.read(drivingSessionProvider.notifier).startSession();
    
    setState(() {
      _statusMessage = 'ACTIVE';
    });
  }

  void _stopDriving() async {
    await ref.read(drivingSessionProvider.notifier).endSession();
    
    setState(() {
      _isDriving = false;
      _statusMessage = 'SYSTEM READY';
      _currentStatus = DetectionStatus.alert;
    });
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return AppTheme.neonGreen;
      case DetectionStatus.slight:
        return AppTheme.neonAmber;
      case DetectionStatus.drowsy:
        return AppTheme.neonRed;
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return 'ALL SYSTEMS NORMAL';
      case DetectionStatus.slight:
        return 'FATIGUE DETECTED';
      case DetectionStatus.drowsy:
        return 'CRITICAL ALERT';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return Icons.check_circle_outline;
      case DetectionStatus.slight:
        return Icons.remove_red_eye_outlined;
      case DetectionStatus.drowsy:
        return Icons.warning_outlined;
    }
  }
}
