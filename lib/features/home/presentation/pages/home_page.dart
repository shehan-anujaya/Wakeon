import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../providers/driving_session_provider.dart';
import '../../../emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../../core/services/drowsiness_detection_service.dart';

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
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.drive_eta_outlined),
              activeIcon: Icon(Icons.drive_eta),
              label: 'Drive',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts_outlined),
              activeIcon: Icon(Icons.contacts),
              label: 'Contacts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
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

class _DrivingScreenState extends ConsumerState<DrivingScreen> {
  DetectionStatus _currentStatus = DetectionStatus.alert;
  String _statusMessage = 'Ready to start';
  bool _isDriving = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(drivingSessionProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0E21),
            const Color(0xFF1A1F3A),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Text(
                    'Wakeon',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Driver Safety Monitor',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: Center(
                child: _isDriving ? _buildCameraPreview() : _buildReadyState(),
              ),
            ),

            // Status Indicator
            _buildStatusIndicator(),

            const SizedBox(height: 24),

            // Control Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: _buildControlButton(session),
            ),

            const SizedBox(height: 32),

            // Session Info
            if (session != null && session.isActive) _buildSessionInfo(session),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    final cameraService = ref.read(cameraServiceProvider);
    
    if (cameraService.controller == null || !cameraService.isInitialized) {
      return const CircularProgressIndicator();
    }

    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CameraPreview(cameraService.controller!),
      ),
    );
  }

  Widget _buildReadyState() {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white24,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam_outlined,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          Text(
            'Camera Off',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white38,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  _statusMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            _getStatusIcon(),
            color: _getStatusColor(),
            size: 32,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(session) {
    final isActive = session?.isActive ?? false;
    
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          if (isActive) {
            _stopDriving();
          } else {
            _startDriving();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 12,
          shadowColor: (isActive ? const Color(0xFFEF5350) : const Color(0xFF4CAF50)).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.stop_circle_outlined : Icons.play_circle_outlined,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              isActive ? 'Stop Monitoring' : 'Start Driving',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoCard(
            icon: Icons.timer_outlined,
            label: 'Duration',
            value: hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
          ),
          _buildInfoCard(
            icon: Icons.warning_amber_outlined,
            label: 'Alerts',
            value: '${session.drowsinessEventsCount}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2746),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _startDriving() async {
    setState(() {
      _isDriving = true;
      _statusMessage = 'Initializing camera...';
    });

    await ref.read(drivingSessionProvider.notifier).startSession();
    
    setState(() {
      _statusMessage = 'Monitoring active';
    });
  }

  void _stopDriving() async {
    await ref.read(drivingSessionProvider.notifier).endSession();
    
    setState(() {
      _isDriving = false;
      _statusMessage = 'Monitoring stopped';
      _currentStatus = DetectionStatus.alert;
    });
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return const Color(0xFF4CAF50);
      case DetectionStatus.slight:
        return const Color(0xFFFFA726);
      case DetectionStatus.drowsy:
        return const Color(0xFFEF5350);
    }
  }

  String _getStatusText() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return 'Alert & Safe';
      case DetectionStatus.slight:
        return 'Slight Fatigue';
      case DetectionStatus.drowsy:
        return 'Drowsy - Wake Up!';
    }
  }

  IconData _getStatusIcon() {
    switch (_currentStatus) {
      case DetectionStatus.alert:
        return Icons.check_circle_outline;
      case DetectionStatus.slight:
        return Icons.warning_amber_outlined;
      case DetectionStatus.drowsy:
        return Icons.error_outline;
    }
  }
}
