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
import 'image_analysis_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DrivingScreen(),
          EmergencyContactsPage(),
          AnalyticsPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: _buildModernNavBar(),
    );
  }

  Widget _buildModernNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              // Sleek gradient background
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.surfaceDark.withOpacity(0.85),
                  AppTheme.surfaceLight.withOpacity(0.75),
                ],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.12),
                width: 1.5,
              ),
              boxShadow: [
                // Outer glow shadow
                BoxShadow(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
                // Deep shadow for depth
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.drive_eta_rounded,
                  label: 'Drive',
                  accentColor: AppTheme.neonGreen,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.contacts_rounded,
                  label: 'Contacts',
                  accentColor: AppTheme.neonBlue,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.insights_rounded,
                  label: 'Analytics',
                  accentColor: AppTheme.neonPurple,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.tune_rounded,
                  label: 'Settings',
                  accentColor: AppTheme.neonAmber,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color accentColor,
  }) {
    final isSelected = _currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentIndex = index);
          // Haptic feedback for better UX
          // HapticFeedback.lightImpact(); // Uncomment if you want haptic feedback
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(
            vertical: isSelected ? 6 : 2, 
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            // Active state gets gradient pill
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accentColor.withOpacity(0.25),
                      accentColor.withOpacity(0.12),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            // Subtle border for active state
            border: isSelected
                ? Border.all(
                    color: accentColor.withOpacity(0.3),
                    width: 1.5,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with smooth transition
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(isSelected ? 4 : 2),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? accentColor.withOpacity(0.2) 
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isSelected ? 23 : 21,
                  color: isSelected ? accentColor : AppTheme.textTertiary,
                ),
              ),
              
              const SizedBox(height: 1),
              
              // Animated label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: GoogleFonts.outfit(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? accentColor : AppTheme.textTertiary,
                  letterSpacing: isSelected ? 0.3 : 0.1,
                  height: 1.0,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              
              // Active indicator dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.only(top: 1),
                width: isSelected ? 3 : 0,
                height: isSelected ? 3 : 0,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrivingScreen extends ConsumerStatefulWidget {
  const DrivingScreen({super.key});

  @override
  ConsumerState<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends ConsumerState<DrivingScreen> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // ignore: unused_field
  DetectionStatus _currentStatus = DetectionStatus.alert;
  bool _isDriving = false;
  late AnimationController _rippleController;
  late AnimationController _pulseController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    final session = ref.watch(drivingSessionProvider);
    
    // Use session's detection status if available
    // ignore: unused_local_variable
    final detectionStatus = session?.currentDetectionStatus ?? DetectionStatus.alert;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundBlack,
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WAKEON',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _isDriving ? AppTheme.neonGreen : AppTheme.textTertiary,
                              shape: BoxShape.circle,
                              boxShadow: _isDriving ? [
                                BoxShadow(
                                  color: AppTheme.neonGreen.withOpacity(0.6),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ] : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isDriving ? 'ACTIVE MONITORING' : 'STANDBY MODE',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _isDriving ? AppTheme.neonGreen : AppTheme.textTertiary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Image Analysis Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImageAnalysisPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.neonBlue.withOpacity(0.2),
                                AppTheme.surfaceDark,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.neonBlue.withOpacity(0.5)),
                          ),
                          child: Icon(
                            Icons.photo_camera_outlined,
                            size: 18,
                            color: AppTheme.neonBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.surfaceLight,
                              AppTheme.surfaceDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.battery_full, size: 18, color: AppTheme.neonGreen),
                            const SizedBox(width: 6),
                            Text(
                              '100%',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main View - Different layouts for driving vs standby
            Expanded(
              child: _isDriving 
                ? _buildProfessionalCameraView(session, detectionStatus)
                : _buildStandbyView(detectionStatus),
            ),

            const SizedBox(height: 20),

            // Session Stats or Start Button
            if (_isDriving && session != null)
              _buildSessionInfo(session)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildStartButton(),
              ),

            // Spacing for bottom nav
            const SizedBox(height: 140),
          ],
        ),
      ],
    ),
      ),
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final progress = (_rippleController.value + delay) % 1.0;
        final opacity = (1.0 - progress) * 0.3;
        final scale = 1.0 + (progress * 0.8);
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.textTertiary.withOpacity(opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Professional full-screen camera monitoring view
  Widget _buildProfessionalCameraView(dynamic session, DetectionStatus detectionStatus) {
    final cameraService = ref.read(cameraServiceProvider);
    final isFaceLockedIn = session?.faceLockedIn == true;
    final statusColor = _getColorForStatus(detectionStatus);
    
    // Calculate session duration
    final duration = session != null 
        ? DateTime.now().difference(session.startTime)
        : Duration.zero;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Main Camera Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: statusColor.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera Feed
                    if (cameraService.controller != null && cameraService.isInitialized)
                      FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: cameraService.controller!.value.previewSize?.height ?? 100,
                          height: cameraService.controller!.value.previewSize?.width ?? 100,
                          child: CameraPreview(cameraService.controller!),
                        ),
                      )
                    else
                      Container(
                        color: AppTheme.backgroundBlack,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppTheme.neonGreen),
                        ),
                      ),
                    
                    // Gradient overlays for depth
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                          stops: const [0.0, 0.15, 0.85, 1.0],
                        ),
                      ),
                    ),
                    
                    // Corner brackets
                    _buildCameraCorners(statusColor),
                    
                    // Top HUD - Status & Timer
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Recording indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.neonRed.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: AppTheme.neonRed.withOpacity(0.5 + (_pulseController.value * 0.5)),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.neonRed.withOpacity(0.6),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'REC',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Session timer
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$minutes:$seconds',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Center crosshair (subtle)
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Bottom status bar
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Row(
                        children: [
                          // Face detection status
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isFaceLockedIn 
                                      ? AppTheme.neonGreen.withOpacity(0.4)
                                      : AppTheme.textTertiary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: (isFaceLockedIn ? AppTheme.neonGreen : AppTheme.textTertiary).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isFaceLockedIn ? Icons.face_retouching_natural : Icons.face_outlined,
                                      size: 18,
                                      color: isFaceLockedIn ? AppTheme.neonGreen : AppTheme.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isFaceLockedIn ? 'FACE LOCKED' : 'SCANNING',
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isFaceLockedIn ? AppTheme.neonGreen : AppTheme.textTertiary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        isFaceLockedIn ? 'Tracking active' : 'Looking for face...',
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 10),
                          
                          // Detection status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  statusColor.withOpacity(0.2),
                                  statusColor.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getIconForStatus(detectionStatus),
                                  size: 20,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  detectionStatus == DetectionStatus.alert 
                                      ? 'ALERT'
                                      : detectionStatus == DetectionStatus.slight
                                          ? 'WARNING'
                                          : 'DANGER',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick Stats Row
          Row(
            children: [
              _buildQuickStat(
                icon: Icons.visibility,
                label: 'Eyes',
                value: isFaceLockedIn ? 'Open' : '--',
                color: AppTheme.neonGreen,
              ),
              const SizedBox(width: 12),
              _buildQuickStat(
                icon: Icons.notifications_active_outlined,
                label: 'Alerts',
                value: '${session?.drowsinessEventsCount ?? 0}',
                color: AppTheme.neonAmber,
              ),
              const SizedBox(width: 12),
              _buildQuickStat(
                icon: Icons.speed,
                label: 'Status',
                value: detectionStatus == DetectionStatus.alert ? 'Good' : 'Check',
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCorners(Color color) {
    return Stack(
      children: [
        Positioned(
          top: 12,
          left: 12,
          child: _buildCornerBracket(color, topLeft: true),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildCornerBracket(color, topRight: true),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: _buildCornerBracket(color, bottomLeft: true),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: _buildCornerBracket(color, bottomRight: true),
        ),
      ],
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      color: AppTheme.textTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Standby view with animated circle
  Widget _buildStandbyView(DetectionStatus detectionStatus) {
    return Center(
      child: SizedBox(
        width: 320,
        height: 320,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Animated Ripples
            _buildRipple(0.0),
            _buildRipple(0.33),
            _buildRipple(0.66),
            
            // Outer Glow
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  width: 280 + (_pulseController.value * 20),
                  height: 280 + (_pulseController.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textTertiary.withOpacity(0.1 + (_pulseController.value * 0.05)),
                        blurRadius: 60 + (_pulseController.value * 20),
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Inner Container
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    AppTheme.surfaceDark,
                    AppTheme.backgroundBlack,
                  ],
                ),
                border: Border.all(
                  color: AppTheme.textTertiary.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildReadyState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket(Color color, {
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
  }) {
    return SizedBox(
      width: 24,
      height: 24,
      child: CustomPaint(
        painter: _CornerBracketPainter(
          color: color,
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        ),
      ),
    );
  }

  Widget _buildReadyState() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color(0xFF1A1A1D),
            Color(0xFF0D0D0F),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Static Professional Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.textTertiary.withOpacity(0.15),
                  AppTheme.textTertiary.withOpacity(0.05),
                ],
              ),
              border: Border.all(
                color: AppTheme.textTertiary.withOpacity(0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.visibility_off_outlined,
              size: 56,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'MONITORING',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppTheme.textTertiary.withOpacity(0.5),
              letterSpacing: 3.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'INACTIVE',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textTertiary,
              letterSpacing: 2.5,
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
        height: 68,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.neonGreen,
              AppTheme.neonGreen.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.5),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppTheme.neonGreen.withOpacity(0.2),
              blurRadius: 40,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_filled, color: Colors.black, size: 30),
            const SizedBox(width: 14),
            Text(
              'START MONITORING',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionInfo(session) {
    // Stats are now shown in the camera view, just show stop button
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: _stopDriving,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonRed.withOpacity(0.15),
                AppTheme.surfaceDark,
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppTheme.neonRed.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neonRed.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stop_rounded, color: AppTheme.neonRed, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'STOP MONITORING',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonRed,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startDriving() async {
    setState(() {
      _isDriving = true;
    });

    await ref.read(drivingSessionProvider.notifier).startSession();
  }

  void _stopDriving() async {
    await ref.read(drivingSessionProvider.notifier).endSession();
    
    setState(() {
      _isDriving = false;
      _currentStatus = DetectionStatus.alert;
    });
  }

  Color _getColorForStatus(DetectionStatus status) {
    switch (status) {
      case DetectionStatus.alert:
        return AppTheme.neonGreen;
      case DetectionStatus.slight:
        return AppTheme.neonAmber;
      case DetectionStatus.drowsy:
        return AppTheme.neonRed;
    }
  }

  IconData _getIconForStatus(DetectionStatus status) {
    switch (status) {
      case DetectionStatus.alert:
        return Icons.check_circle;
      case DetectionStatus.slight:
        return Icons.warning_rounded;
      case DetectionStatus.drowsy:
        return Icons.error_rounded;
    }
  }
}

/// Custom painter for minimal corner brackets
class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final bool topLeft;
  final bool topRight;
  final bool bottomLeft;
  final bool bottomRight;

  _CornerBracketPainter({
    required this.color,
    this.topLeft = false,
    this.topRight = false,
    this.bottomLeft = false,
    this.bottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const length = 12.0;

    if (topLeft) {
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    } else if (topRight) {
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, length);
    } else if (bottomLeft) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    } else if (bottomRight) {
      path.moveTo(size.width - length, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - length);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
