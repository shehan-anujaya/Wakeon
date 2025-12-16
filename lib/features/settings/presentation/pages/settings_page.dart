import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: const Color(0xFF4CAF50),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Text(
                            'Customize your experience',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Detection Settings
              _buildSection(
                context,
                title: 'Detection Settings',
                children: [
                  _buildSliderSetting(
                    context,
                    ref,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Eye Closure Threshold',
                    value: settings.eyeClosureThreshold,
                    min: AppConstants.minEyeClosureThreshold,
                    max: AppConstants.maxEyeClosureThreshold,
                    divisions: 8,
                    unit: 's',
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateEyeClosureThreshold(value);
                    },
                  ),
                ],
              ),

              // Alert Settings
              _buildSection(
                context,
                title: 'Alert Settings',
                children: [
                  _buildSliderSetting(
                    context,
                    ref,
                    icon: Icons.volume_up_outlined,
                    label: 'Alert Volume',
                    value: settings.alertVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    unit: '%',
                    displayMultiplier: 100,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).updateAlertVolume(value);
                    },
                  ),
                  _buildSwitchSetting(
                    context,
                    icon: Icons.record_voice_over_outlined,
                    label: 'Voice Alerts',
                    subtitle: 'Spoken warnings when drowsy',
                    value: settings.enableVoiceAlerts,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleVoiceAlerts(value);
                    },
                  ),
                  _buildSwitchSetting(
                    context,
                    icon: Icons.vibration_outlined,
                    label: 'Vibration',
                    subtitle: 'Vibrate on alerts',
                    value: settings.enableVibration,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleVibration(value);
                    },
                  ),
                  _buildSwitchSetting(
                    context,
                    icon: Icons.flash_on_outlined,
                    label: 'Screen Flash',
                    subtitle: 'Flash screen on alerts',
                    value: settings.enableFlashScreen,
                    onChanged: (value) {
                      // Implement screen flash toggle
                    },
                  ),
                ],
              ),

              // Performance Settings
              _buildSection(
                context,
                title: 'Performance',
                children: [
                  _buildSwitchSetting(
                    context,
                    icon: Icons.battery_saver_outlined,
                    label: 'Battery Optimization',
                    subtitle: 'Reduce battery usage',
                    value: settings.batteryOptimization,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleBatteryOptimization(value);
                    },
                  ),
                ],
              ),

              // Privacy & Legal
              _buildSection(
                context,
                title: 'Privacy & Legal',
                children: [
                  _buildTileSetting(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    label: 'Privacy Policy',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildTileSetting(
                    context,
                    icon: Icons.description_outlined,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),

              // About
              _buildSection(
                context,
                title: 'About',
                children: [
                  _buildTileSetting(
                    context,
                    icon: Icons.info_outlined,
                    label: 'App Version',
                    trailing: Text(
                      '1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF4CAF50),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E2746),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    double displayMultiplier = 1,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                '${(value * displayMultiplier).toStringAsFixed(displayMultiplier == 1 ? 1 : 0)}$unit',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF4CAF50),
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveTrackColor: Colors.white24,
              thumbColor: const Color(0xFF4CAF50),
              overlayColor: const Color(0xFF4CAF50).withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildTileSetting(
    BuildContext context, {
    required IconData icon,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2746),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Privacy Policy',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: SingleChildScrollView(
          child: Text(
            AppConstants.privacyPolicy,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
