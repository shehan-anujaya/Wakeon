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
  bool _isDriving = false;
  late AnimationController _rippleController;
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _gridController;

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
    
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pulseController.dispose();
    _scanController.dispose();
    _gridController.dispose();
    super.dispose();
  }

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
              child: Center(
                child: Stack(
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
                        return Container(
                          width: 280 + (_pulseController.value * 20),
                          height: 280 + (_pulseController.value * 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor().withOpacity(0.15 + (_pulseController.value * 0.1)),
                                blurRadius: 80 + (_pulseController.value * 40),
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    // Progress/Status Ring
                    SizedBox(
                      width: 290,
                      height: 290,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor().withOpacity(0.4)),
                      ),
                    ),
                    
                    // Inner Camera/Status Container
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.surfaceDark,
                            AppTheme.backgroundBlack,
                          ],
                        ),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.6),
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
                    
                    // Status Icon Badge
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.surfaceLight,
                              AppTheme.surfaceDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _getStatusColor().withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(),
                              color: _getStatusColor(),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _getStatusText(),
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
    
    if (cameraService.controller == null || !cameraService.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.neonGreen),
        ),
      );
    }

    // Calculate scale to fill the circular container
    final size = 250.0;
    final scale = size / MediaQuery.of(context).size.width.clamp(size, size * 2);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview - scaled to fill the entire circular area
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size,
              height: size,
              child: CameraPreview(cameraService.controller!),
            ),
          ),
        ),
        
        // Dark overlay for better visibility
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
              stops: const [0.5, 1.0],
            ),
          ),
        ),
        
        // Scanning Grid Overlay
        _buildScanningGrid(),
        
        // Corner Brackets (with proper clipping)
        Padding(
          padding: const EdgeInsets.all(15),
          child: _buildCornerBrackets(),
        ),
        
        // Horizontal Scanning Line
        _buildScanLine(),
        
        // Detection Indicators
        _buildDetectionIndicators(),
        
        // Face Detection Frame (placeholder - would normally use ML Kit data)
        _buildFaceDetectionFrame(),
      ],
    );
  }

  Widget _buildScanningGrid() {
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, child) {
        return CustomPaint(
          painter: GridPainter(
            color: AppTheme.neonGreen.withOpacity(0.15 + (_gridController.value * 0.1)),
          ),
          child: Container(),
        );
      },
    );
  }

  Widget _buildCornerBrackets() {
    return CustomPaint(
      painter: CornerBracketsPainter(
        color: _getStatusColor(),
        strokeWidth: 3,
      ),
      child: Container(),
    );
  }

  Widget _buildScanLine() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: _scanController.value * 250,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _getStatusColor().withOpacity(0.8),
                  _getStatusColor(),
                  _getStatusColor().withOpacity(0.8),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor().withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectionIndicators() {
    return Positioned(
      top: 15,
      left: 15,
      right: 15,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIndicatorDot('EYE', _isDriving),
          _buildIndicatorDot('FACE', _isDriving),
          _buildIndicatorDot('ALERT', _currentStatus == DetectionStatus.alert),
        ],
      ),
    );
  }

  Widget _buildIndicatorDot(String label, bool active) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active 
                  ? AppTheme.neonGreen.withOpacity(0.6) 
                  : AppTheme.textTertiary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppTheme.neonGreen : AppTheme.textTertiary,
                  shape: BoxShape.circle,
                  boxShadow: active ? [
                    BoxShadow(
                      color: AppTheme.neonGreen.withOpacity(_pulseController.value),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: active ? AppTheme.neonGreen : AppTheme.textTertiary,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaceDetectionFrame() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 140,
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(
                color: _getStatusColor().withOpacity(0.4 + (_pulseController.value * 0.2)),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(80),
            ),
            child: Stack(
              children: [
                // Eye tracking indicators
                Positioned(
                  top: 50,
                  left: 30,
                  child: _buildEyeIndicator(),
                ),
                Positioned(
                  top: 50,
                  right: 30,
                  child: _buildEyeIndicator(),
                ),
                // Status text at bottom
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'TRACKING',
                        style: GoogleFonts.outfit(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: _getStatusColor(),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEyeIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getStatusColor().withOpacity(_pulseController.value * 0.8),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            const Color(0xFF1A1A1D),
            const Color(0xFF0D0D0F),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Eye Icon
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.textTertiary.withOpacity(0.1),
                    border: Border.all(
                      color: AppTheme.textTertiary.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 60,
                    color: AppTheme.textTertiary.withOpacity(0.4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            'MONITORING',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.textTertiary.withOpacity(0.6),
              letterSpacing: 3.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'INACTIVE',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textTertiary,
              letterSpacing: 2.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.textTertiary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              'READY TO START',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiary.withOpacity(0.7),
                letterSpacing: 1.5,
              ),
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

// Custom Painter for Corner Brackets
class CornerBracketsPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CornerBracketsPainter({
    required this.color,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const bracketLength = 30.0;
    
    // Top-left corner
    canvas.drawLine(const Offset(0, 0), const Offset(bracketLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, bracketLength), paint);
    
    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - bracketLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, bracketLength), paint);
    
    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(bracketLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - bracketLength), paint);
    
    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - bracketLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - bracketLength), paint);
  }

  @override
  bool shouldRepaint(covariant CornerBracketsPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

// Custom Painter for Scanning Grid
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const gridSize = 25.0;
    
    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
