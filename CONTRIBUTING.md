# Contributing to Wakeon 🤝

Thank you for your interest in contributing to Wakeon! This document provides guidelines and instructions for contributing.

## 🎯 How Can I Contribute?

### 🐛 Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Device information** (OS, version, device model)
- **App version**

### 💡 Suggesting Features

Feature suggestions are welcome! Please include:

- **Clear use case** - Why is this feature needed?
- **Detailed description** - How should it work?
- **Alternative solutions** - What other approaches did you consider?
- **Mockups/Examples** - Visual aids help!

### 🔧 Pull Requests

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes**
4. **Follow coding standards** (see below)
5. **Test thoroughly**
6. **Commit with clear messages** (`git commit -m 'Add amazing feature'`)
7. **Push to your branch** (`git push origin feature/amazing-feature`)
8. **Open a Pull Request**

## 📝 Coding Standards

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- Use `lowerCamelCase` for variables, methods, and parameters
- Use `UpperCamelCase` for classes and types
- Use `lowercase_with_underscores` for library names
- Prefer `const` constructors when possible
- Use trailing commas for better formatting

### Flutter Best Practices

- **Keep widgets small** - Break down complex widgets
- **Separate business logic** - Use providers/services
- **Const constructors** - Use `const` for static widgets
- **Avoid setState abuse** - Use proper state management
- **Meaningful names** - Clear, descriptive naming

### Example Code Style

```dart
// Good ✅
class DriverSessionCard extends StatelessWidget {
  const DriverSessionCard({
    super.key,
    required this.session,
    this.onTap,
  });

  final DrivingSession session;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(session.formattedDuration),
        ),
      ),
    );
  }
}

// Bad ❌
class driverCard extends StatelessWidget {
  driverCard({this.s, this.cb});
  var s;
  var cb;
  
  Widget build(ctx) {
    return GestureDetector(
      onTap: cb,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(s.duration),
        ),
      ),
    );
  }
}
```

## 🧪 Testing

### Before Submitting PR

- [ ] All existing tests pass
- [ ] New features have tests
- [ ] Code is formatted (`flutter format .`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Tested on physical device
- [ ] Tested different screen sizes
- [ ] Tested light and dark mode (if applicable)

### Writing Tests

```dart
// Unit test example
test('DrivingSession calculates duration correctly', () {
  final session = DrivingSession(
    id: '1',
    startTime: DateTime(2025, 1, 1, 10, 0),
    endTime: DateTime(2025, 1, 1, 12, 30),
  );
  
  expect(session.duration, equals(Duration(hours: 2, minutes: 30)));
  expect(session.formattedDuration, equals('2h 30m'));
});

// Widget test example
testWidgets('DriveButton shows correct text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DriveButton(
          isActive: false,
          onPressed: () {},
        ),
      ),
    ),
  );
  
  expect(find.text('Start Driving'), findsOneWidget);
});
```

## 📁 Project Structure

When adding new features, follow the clean architecture pattern:

```
lib/
├── core/
│   ├── constants/
│   ├── models/
│   ├── services/
│   └── theme/
├── features/
│   └── your_feature/
│       ├── data/
│       │   ├── datasources/
│       │   └── repositories/
│       ├── domain/
│       │   └── entities/
│       ├── presentation/
│       │   ├── pages/
│       │   ├── widgets/
│       │   └── providers/
```

## 🎨 UI/UX Guidelines

- Follow Material Design 3 principles
- Maintain dark-mode first approach
- Ensure accessibility (contrast, font sizes)
- Keep animations smooth (60fps)
- Design for driver safety (minimal distraction)
- Use consistent spacing and colors

## 📱 Device Testing

Test on multiple configurations:

- **Android**: Various versions (API 21+)
- **Screen sizes**: Phone, tablet
- **Orientations**: Portrait and landscape
- **Real devices**: Camera functionality

## 🔒 Security & Privacy

- **No data collection** without user consent
- **Local processing** - keep ML on-device
- **Secure storage** - encrypt sensitive data
- **Permission requests** - clear explanations
- **GDPR compliance** - user data rights

## 📋 Commit Message Format

Use conventional commits:

```
type(scope): subject

body

footer
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, missing semicolons
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

**Examples:**
```
feat(detection): add head tilt detection

Implement head tilt angle calculation using face landmarks.
Triggers alert when head tilts beyond threshold for 3 seconds.

Closes #123
```

```
fix(alerts): prevent multiple simultaneous alarms

Add check to prevent alert service from triggering multiple
concurrent alarms which was causing audio overlap.
```

## 🏆 Recognition

Contributors will be:
- Listed in README.md
- Credited in release notes
- Acknowledged in the app (if major contribution)

## 📞 Questions?

- Open a discussion on GitHub
- Tag maintainers in issues
- Join our community chat

## 📜 Code of Conduct

Be respectful, inclusive, and professional. We want Wakeon to be welcoming to all contributors.

---

Thank you for making Wakeon better! 🙏
