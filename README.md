# Wakeon - Driver Drowsiness Detection System 🚗💤

<div align="center">
  <img src="assets/images/logo.png" alt="Wakeon Logo" width="200"/>
  
  ### Stay Alert. Drive Safe.
  
  A modern, professional Flutter mobile application focused on road safety and real-time fatigue prevention.

  [![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

---

## 🎯 Overview

**Wakeon** is an intelligent driver safety application that uses advanced computer vision and AI to monitor driver alertness in real-time. By analyzing eye movements, blink patterns, and facial behavior through the front camera, Wakeon detects early signs of drowsiness and takes immediate preventive actions to keep drivers safe.

### Why Wakeon?

- **Real-time Detection**: Continuous monitoring using on-device AI
- **Privacy-First**: All processing happens locally - no data stored or transmitted
- **Multi-layered Alerts**: Audio alarms, voice alerts, vibration, and screen flash
- **Emergency Protection**: Automatic contact notification with location sharing
- **Data Insights**: Comprehensive analytics to understand fatigue patterns
- **Production-Ready**: Built with clean architecture and professional UX/UI

---

## ✨ Key Features

### 👁️ **Drowsiness Detection**
- Real-time eye tracking using front camera
- Detects prolonged eye closure (configurable threshold)
- Monitors blink frequency patterns
- Smart detection algorithms with minimal false positives

### 🚨 **Alert & Safety System**
- **Immediate Alerts**: Loud alarm when drowsiness detected
- **Voice Warnings**: Clear, calm Text-to-Speech alerts
- **Multi-sensory**: Screen flash & vibration feedback
- **Escalation Logic**: Progressive alert system from warning to emergency

### 📞 **Emergency Contact Management**
- Add and manage multiple emergency contacts
- Auto-SMS with GPS location
- Auto-call primary contact option
- Customizable per-contact preferences

### 📊 **Driver Insights & Analytics**
- Detailed driving session history
- Drowsiness incident timeline
- Visual charts showing fatigue patterns
- Weekly safety summaries
- Safety score calculations

### ⚙️ **Customizable Settings**
- Adjustable eye closure threshold (1-5 seconds)
- Alert volume control
- Voice alert language selection
- Battery-saving mode
- Sensitivity adjustments

---

## 🎨 Design Philosophy

### Material Design 3
- Modern, minimal, dark-mode first UI
- Optimized for night driving visibility
- Smooth animations and transitions
- Premium glassmorphism effects

### Color Palette
- **Primary Dark**: `#0A0E21` - Deep charcoal background
- **Secondary Dark**: `#1A1F3A` - Surface color
- **Safe Green**: `#4CAF50` - Alert state
- **Warning Amber**: `#FFA726` - Slight fatigue
- **Danger Red**: `#EF5350` - Drowsy state

### Typography
- **Font**: Google Fonts (Poppins)
- Large, readable text suitable for quick glances
- Clear visual hierarchy

---

## 🏗️ Architecture

### Clean Architecture Pattern
```
lib/
├── core/
│   ├── constants/         # App-wide constants
│   ├── models/           # Data models
│   ├── services/         # Core services (Camera, Detection, Alert, etc.)
│   ├── theme/            # App theming
│   └── router/           # Navigation
├── features/
│   ├── onboarding/       # Onboarding flow
│   ├── home/             # Main driving screen
│   ├── emergency_contacts/  # Contact management
│   ├── analytics/        # Analytics & insights
│   └── settings/         # App settings
└── main.dart
```

### State Management
- **Riverpod 2.4+**: Robust, testable state management
- Provider-based architecture
- Separation of concerns

### Key Services
- `CameraService`: Camera initialization and image streaming
- `DrowsinessDetectionService`: AI-powered drowsiness detection
- `AlertService`: Multi-modal alert system
- `EmergencyService`: SMS and call handling
- `LocationService`: GPS location retrieval

---

## 📦 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.0+ |
| **Language** | Dart 3.0+ |
| **State Management** | Riverpod |
| **Camera** | camera package |
| **ML/AI** | Google ML Kit, TensorFlow Lite |
| **Notifications** | flutter_local_notifications |
| **Audio** | audioplayers, flutter_tts |
| **Storage** | Hive, shared_preferences |
| **Charts** | fl_chart |
| **Location** | geolocator |
| **Permissions** | permission_handler |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / VS Code with Flutter extensions
- Physical device (camera required)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/wakeon.git
   cd wakeon
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (for Riverpod and Hive)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
Add the following permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.CALL_PHONE" />
```

#### iOS
Add the following to `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera is used to detect drowsiness while driving</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is shared with emergency contacts during alerts</string>
```

---

## 📱 Screenshots

> **Note**: Add screenshots of your app here after running it:
> - Onboarding screens
> - Home/Driving screen
> - Emergency contacts
> - Analytics dashboard
> - Settings page

---

## 🔒 Privacy & Security

### Local Processing
- All drowsiness detection happens on-device
- No video or images are stored
- No data transmitted to servers

### Data Storage
- Session statistics stored locally using Hive
- User settings in SharedPreferences
- Users can delete all data anytime

### Permissions
- Camera: Real-time face detection only
- Location: Shared only during emergencies
- SMS/Phone: Used only for emergency contacts

---

## 🛣️ Roadmap

- [ ] iOS Support
- [ ] Head tilt/nodding detection
- [ ] Yawn detection
- [ ] Cloud backup (optional)
- [ ] Multi-language support
- [ ] Apple Watch integration
- [ ] Android Auto / CarPlay support
- [ ] Drive mode automation (Bluetooth trigger)
- [ ] Advanced ML models for better accuracy

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run with coverage
flutter test --coverage
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@shehan-anujaya](https://github.com/shehan-anujaya)
- LinkedIn: [Shehan Anujaya](https://www.linkedin.com/in/shehan-anujaya-285642370/)

---

## 🙏 Acknowledgments

- Google ML Kit for face detection
- Flutter team for the amazing framework
- Material Design team for design guidelines
- All open-source contributors

---

## ⚠️ Disclaimer

**Wakeon is designed to assist drivers but should not be solely relied upon for safety. Always drive responsibly, take breaks when tired, and never use your phone while driving.**

---

<div align="center">
  Made with ❤️ using Flutter
  
  **Stay Alert. Drive Safe. Save Lives.**
</div>
