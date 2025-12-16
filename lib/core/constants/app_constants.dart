class AppConstants {
  // App Info
  static const String appName = 'Wakeon';
  static const String appTagline = 'Stay Alert. Drive Safe.';
  
  // Detection Settings
  static const double defaultEyeClosureThreshold = 2.5; // seconds
  static const double minEyeClosureThreshold = 1.0;
  static const double maxEyeClosureThreshold = 5.0;
  static const int defaultBlinkThreshold = 5; // blinks per 10 seconds
  
  // Alert Settings
  static const double defaultAlertVolume = 0.8;
  static const int alertEscalationTime = 10; // seconds before calling emergency
  
  // Storage Keys
  static const String onboardingKey = 'has_seen_onboarding';
  static const String settingsBox = 'settings';
  static const String sessionBox = 'sessions';
  static const String contactsBox = 'emergency_contacts';
  static const String eventsBox = 'drowsiness_events';
  
  // Notification
  static const String notificationChannelId = 'wakeon_alerts';
  static const String notificationChannelName = 'Wakeon Alerts';
  static const String notificationChannelDescription = 'Drowsiness detection alerts';
  
  // SMS Template
  static const String emergencySmsTemplate = 
      '🚨 WAKEON ALERT: Driver showing signs of drowsiness. Last known location: {location}. Please check on them immediately.';
  
  // Privacy
  static const String privacyPolicy = '''
Wakeon Privacy Policy

Your Privacy Matters

1. Data Collection
   - All drowsiness detection happens on your device
   - No video or images are stored or transmitted
   - Only session statistics are saved locally

2. Camera Usage
   - Camera is used only for real-time face detection
   - No recordings are made
   - Processing happens entirely on your device

3. Location Data
   - Location is accessed only during emergencies
   - Shared only with your chosen emergency contacts
   - Not stored or tracked otherwise

4. Emergency Contacts
   - Contact information stays on your device
   - Used only when alerts are triggered
   - You control who receives alerts

5. Analytics
   - Session data stored locally for your insights
   - No data shared with third parties
   - You can delete your data anytime

We are committed to protecting your privacy and ensuring transparent data practices.
''';
}
