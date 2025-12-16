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
                  icon: Icons.emergency_rounded,
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

class _DrivingScreenState extends ConsumerState<DrivingScreen> with TickerProviderStateMixin {
  DetectionStatus _currentStatus = DetectionStatus.alert;
  String _statusMessage = 'SYSTEM READY';
  bool _isDriving = false;
  late AnimationController _rippleController;
  late AnimationController _pulseController;

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
    final session = ref.watch(drivingSessionProvider);
    
    // Use session's detection status if available
    final detectionStatus = session?.currentDetectionStatus ?? DetectionStatus.alert;
    final statusMessage = session?.currentStatusMessage ?? 'SYSTEM READY';

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
            ),

            const SizedBox(height: 40),

            // Main Dashboard Circle with Ripples
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: SizedBox(
                      width: 320,
                      height: 320,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Animated Ripples (only when not driving)
                          if (!_isDriving) ...[
                            _buildRipple(0.0),
                            _buildRipple(0.33),
                            _buildRipple(0.66),
                          ],
                          
                          // Outer Glow
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final statusColor = _getColorForStatus(detectionStatus);
                              return Container(
                                width: 280 + (_pulseController.value * 20),
                                height: 280 + (_pulseController.value * 20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withOpacity(0.15 + (_pulseController.value * 0.1)),
                                      blurRadius: 80 + (_pulseController.value * 40),
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          // Progress/Status Ring
                          const SizedBox(
                            width: 290,
                            height: 290,
                            child: SizedBox.shrink(),
                          ),
                          
                          // Animated Ring
                          SizedBox(
                            width: 290,
                            height: 290,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(_getColorForStatus(detectionStatus).withOpacity(0.4)),
                            ),
                          ),
                          
                          // Inner Camera/Status Container - Fixed position
                          Positioned(
                            top: 35,
                            left: 35,
                            child: Container(
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
                                  color: _getColorForStatus(detectionStatus).withOpacity(0.6),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _isDriving 
                                  ? _buildCameraPreview() 
                                  : _buildReadyState(),
                              ),
                            ),
                          ),
                          
                          // Warning Status Overlay (only when drowsy or slight)
                          if (_isDriving && detectionStatus != DetectionStatus.alert)
                            Positioned(
                              bottom: 25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getColorForStatus(detectionStatus).withOpacity(0.95),
                                      _getColorForStatus(detectionStatus).withOpacity(0.85),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getColorForStatus(detectionStatus).withOpacity(0.6),
                                      blurRadius: 20,
                                      offset: const Offset(0, 5),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconForStatus(detectionStatus),
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _getTextForStatus(detectionStatus),
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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

  Widget _buildCameraPreview() {
    final cameraService = ref.read(cameraServiceProvider);
    final session = ref.watch(drivingSessionProvider);
    
    if (cameraService.controller == null || !cameraService.isInitialized) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      );
    }

    // Check if face is detected properly
    final detectionStatus = session?.currentDetectionStatus;
    final isFaceDetected = session?.currentStatusMessage != 'No face detected';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Feed
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: cameraService.controller!.value.previewSize?.height ?? 100,
              height: cameraService.controller!.value.previewSize?.width ?? 100,
              child: CameraPreview(cameraService.controller!),
            ),
          ),
        ),
        
        // Face Positioning Guide Overlay
        if (!isFaceDetected)
          _buildFacePositioningGuide(),
        
        // Face Detected Success Indicator (appears briefly when face is found)
        if (isFaceDetected && detectionStatus == DetectionStatus.alert)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'FACE DETECTED',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFacePositioningGuide() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.6),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Corner Frame Guides
          Positioned(
            top: 30,
            left: 30,
            child: _buildCornerGuide(isTopLeft: true),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: _buildCornerGuide(isTopRight: true),
          ),
          Positioned(
            bottom: 30,
            left: 30,
            child: _buildCornerGuide(isBottomLeft: true),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: _buildCornerGuide(isBottomRight: true),
          ),
          
          // Center Face Oval Guide
          Center(
            child: Container(
              width: 140,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: AppTheme.neonAmber,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonAmber.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          
          // Instruction Text
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.face_outlined,
                  color: AppTheme.neonAmber,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'POSITION YOUR FACE',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neonAmber,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Align face in center frame',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerGuide({
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: (isTopLeft || isTopRight)
              ? BorderSide(color: AppTheme.neonAmber, width: 3)
              : BorderSide.none,
          bottom: (isBottomLeft || isBottomRight)
              ? BorderSide(color: AppTheme.neonAmber, width: 3)
              : BorderSide.none,
          left: (isTopLeft || isBottomLeft)
              ? BorderSide(color: AppTheme.neonAmber, width: 3)
              : BorderSide.none,
          right: (isTopRight || isBottomRight)
              ? BorderSide(color: AppTheme.neonAmber, width: 3)
              : BorderSide.none,
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
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.surfaceLight.withOpacity(0.5),
                  AppTheme.surfaceDark.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('DURATION', hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m', Icons.timer_outlined),
                Container(
                  width: 1,
                  height: 40,
                  color: AppTheme.borderColor,
                ),
                _buildStatItem('ALERTS', '${session.drowsinessEventsCount}', Icons.notifications_active_outlined),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Stop Button
          GestureDetector(
            onTap: _stopDriving,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.surfaceLight,
                    AppTheme.surfaceDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppTheme.neonRed.withOpacity(0.6),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stop_circle_outlined, color: AppTheme.neonRed, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'STOP MONITORING',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.neonRed,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.neonGreen, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textTertiary,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
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

  String _getTextForStatus(DetectionStatus status) {
    switch (status) {
      case DetectionStatus.alert:
        return 'ALL SYSTEMS NORMAL';
      case DetectionStatus.slight:
        return 'FATIGUE WARNING';
      case DetectionStatus.drowsy:
        return 'DROWSINESS ALERT!';
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
