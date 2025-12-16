import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/settings_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.settings_suggest_outlined,
                        color: AppTheme.neonGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SETTINGS',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'Configure Wakeon',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Detection Settings
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'DETECTION',
                children: [
                  _buildSliderSetting(
                    context,
                    ref,
                    icon: Icons.remove_red_eye_rounded,
                    label: 'Eye Closure Sensitivity',
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
            ),

            // Alert Settings
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'ALERTS & NOTIFICATIONS',
                children: [
                  _buildSliderSetting(
                    context,
                    ref,
                    icon: Icons.volume_up_rounded,
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
                    icon: Icons.record_voice_over_rounded,
                    label: 'Voice Alerts',
                    subtitle: 'Spoken warnings',
                    value: settings.enableVoiceAlerts,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleVoiceAlerts(value);
                    },
                  ),
                  _buildSwitchSetting(
                    context,
                    icon: Icons.vibration_rounded,
                    label: 'Vibration',
                    subtitle: 'Haptic feedback',
                    value: settings.enableVibration,
                    activeColor: AppTheme.neonAmber,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleVibration(value);
                    },
                  ),
                  _buildSwitchSetting(
                    context,
                    icon: Icons.flash_on_rounded,
                    label: 'Screen Flash',
                    subtitle: 'Visual warning',
                    value: settings.enableFlashScreen,
                    activeColor: AppTheme.neonRed,
                    onChanged: (value) {
                      // Implement screen flash toggle
                    },
                  ),
                ],
              ),
            ),

            // Performance Settings
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'PERFORMANCE',
                children: [
                  _buildSwitchSetting(
                    context,
                    icon: Icons.battery_saver_rounded,
                    label: 'Battery Optimization',
                    subtitle: 'Reduce usage',
                    value: settings.batteryOptimization,
                    activeColor: AppTheme.neonBlue,
                    onChanged: (value) {
                      ref.read(settingsProvider.notifier).toggleBatteryOptimization(value);
                    },
                  ),
                ],
              ),
            ),

            // Privacy & Legal
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'LEGAL',
                children: [
                  _buildTileSetting(
                    context,
                    icon: Icons.privacy_tip_rounded,
                    label: 'Privacy Policy',
                    onTap: () => _showPrivacyPolicy(context),
                  ),
                  _buildTileSetting(
                    context,
                    icon: Icons.description_rounded,
                    label: 'Terms of Service',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // About
            SliverToBoxAdapter(
              child: _buildSection(
                context,
                title: 'ABOUT',
                children: [
                  _buildTileSetting(
                    context,
                    icon: Icons.info_outline_rounded,
                    label: 'App Version',
                    trailing: Text(
                      '1.0.0',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textTertiary,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.borderColor),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.textSecondary, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(value * displayMultiplier).toStringAsFixed(displayMultiplier == 1 ? 1 : 0)}$unit',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.neonGreen,
              inactiveTrackColor: AppTheme.surfaceLight,
              thumbColor: AppTheme.neonGreen,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayColor: AppTheme.neonGreen.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
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
    Color? activeColor,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.backgroundBlack,
            activeTrackColor: activeColor ?? AppTheme.neonGreen,
            inactiveThumbColor: AppTheme.textTertiary,
            inactiveTrackColor: AppTheme.surfaceLight,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.borderColor),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            AppConstants.privacyPolicy,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'CLOSE',
              style: GoogleFonts.outfit(
                color: AppTheme.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
