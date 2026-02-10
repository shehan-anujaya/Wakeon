import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/models/emergency_contact.dart';
import 'core/models/user_model.dart';
import 'core/models/driving_session.dart';
import 'core/models/drowsiness_event.dart';
import 'core/adapters/duration_adapter.dart';
import 'features/onboarding/data/datasources/local_datasource.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/presentation/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register all Hive type adapters
  // Duration adapter must be registered first since it's used by other types
  Hive.registerAdapter(DurationAdapter());
  Hive.registerAdapter(EmergencyContactAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(DrivingSessionAdapter());
  Hive.registerAdapter(DrowsinessEventAdapter());
  Hive.registerAdapter(DrowsinessLevelAdapterAdapter());

  // Initialize auth repository
  final authRepository = AuthRepository();
  await authRepository.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style - Modern dark matte
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      // Match the bottom nav bar color from AppTheme
      systemNavigationBarColor: Color(0xFF18181B), 
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
      ],
      child: const WakeonApp(),
    ),
  );
}

class WakeonApp extends ConsumerWidget {
  const WakeonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final hasSeenOnboarding = ref.watch(hasSeenOnboardingProvider);

    return MaterialApp(
      title: 'Wakeon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: _buildHome(authState, hasSeenOnboarding),
    );
  }

  Widget _buildHome(AuthState authState, AsyncValue<bool> hasSeenOnboarding) {
    // Show splash while loading
    if (authState.status == AuthStatus.initial ||
        authState.status == AuthStatus.loading) {
      return const SplashScreen();
    }

    // Require authentication
    if (authState.status != AuthStatus.authenticated) {
      return const LoginPage();
    }

    // User is authenticated - check onboarding
    return hasSeenOnboarding.when(
      data: (seen) => AppRouter.getInitialRoute(seen),
      loading: () => const SplashScreen(),
      error: (_, __) => AppRouter.getInitialRoute(false),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern icon with glow effect
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 60,
                color: AppTheme.neonGreen,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Wakeon',
              style: GoogleFonts.outfit(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Stay Alert. Drive Safe.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
