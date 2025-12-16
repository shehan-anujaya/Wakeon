# Assets Directory

This directory contains app assets including:

## Images
- Logo and branding
- Onboarding illustrations
- Icons and badges

## Sounds
- alarm.mp3 - Alert sound for drowsiness detection

## Animations
- Lottie animations for onboarding and alerts

## Icons
- Custom icon font (if needed)

## Usage

All assets are referenced in pubspec.yaml and can be loaded using:

```dart
// Images
Image.asset('assets/images/logo.png')

// Sounds
AudioPlayer().play(AssetSource('sounds/alarm.mp3'))

// Animations
Lottie.asset('assets/animations/alert.json')
```

## Adding New Assets

1. Place files in appropriate subdirectory
2. Update pubspec.yaml if needed
3. Run `flutter pub get`
4. Access via asset path
