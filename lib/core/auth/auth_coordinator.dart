import 'package:hive_flutter/hive_flutter.dart';

// ============================================================================
// AUTH COORDINATOR  — Singleton
// Manages persistent authentication state via a Hive box.
// Follows the same Coordinator pattern used by CartCoordinator,
// WishlistCoordinator, etc.
// ============================================================================

class AuthCoordinator {
  AuthCoordinator._();

  static final AuthCoordinator instance = AuthCoordinator._();

  static const _boxName = 'auth';
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyOnboarding = 'onboardingCompleted';

  Box? _box;
  bool _initialized = false;

  /// Call once from main() before runApp.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _box = await Hive.openBox(_boxName);
  }

  /// Whether a user session is currently active.
  bool get isLoggedIn => _box?.get(_keyLoggedIn, defaultValue: false) ?? false;

  /// Whether the user has already seen the onboarding flow.
  bool get onboardingCompleted =>
      _box?.get(_keyOnboarding, defaultValue: false) ?? false;

  /// Persist login state (true on successful OTP verification).
  Future<void> setLoggedIn(bool value) async {
    await _box?.put(_keyLoggedIn, value);
  }

  /// Mark onboarding as seen so it is skipped on subsequent launches.
  Future<void> setOnboardingCompleted() async {
    await _box?.put(_keyOnboarding, true);
  }

  /// Clear session and reset onboarding so the full flow replays after logout.
  Future<void> logout() async {
    await _box?.put(_keyLoggedIn, false);
    await _box?.put(_keyOnboarding, false);
  }
}
