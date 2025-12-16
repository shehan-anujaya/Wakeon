import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _onboardingKey = 'has_seen_onboarding';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return prefs.getBool(_onboardingKey) ?? false;
});

class OnboardingNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  OnboardingNotifier(this._prefs) : super(_prefs.getBool(_onboardingKey) ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_onboardingKey, true);
    state = true;
  }
}

final onboardingNotifierProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  return OnboardingNotifier(prefs!);
});
