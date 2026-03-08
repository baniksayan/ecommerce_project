import '../core/auth/auth_coordinator.dart';

// ============================================================================
// AUTH VIEWMODEL
// Handles per-screen state: email validation, mock OTP send/verify.
// Persistent auth state lives in AuthCoordinator (Hive).
//
// Future API hooks are noted inline for easy swap:
//   POST /auth/send-otp
//   POST /auth/verify-otp
// ============================================================================

class AuthViewModel {
  // ── Convenience passthrough to coordinator ────────────────────────────────

  static bool get isLoggedIn => AuthCoordinator.instance.isLoggedIn;

  static Future<void> logout() => AuthCoordinator.instance.logout();

  // ── Email validation ──────────────────────────────────────────────────────

  /// Returns an error message string, or null when the email is valid.
  String? validateEmail(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Email address is required.';
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  // ── OTP flow (mock — swap bodies with API calls when backend is ready) ────

  /// Simulates sending an OTP to [email].
  /// Returns true on success, false on failure.
  ///
  /// Future: replace body with POST /auth/send-otp
  Future<bool> sendOtp(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: call API and handle HTTP errors
    return true;
  }

  /// Simulates verifying [code] for [email].
  /// Persists login state on success.
  ///
  /// Future: replace body with POST /auth/verify-otp
  Future<bool> verifyOtp({
    required String email,
    required String code,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // TODO: validate code against server response
    if (code.length == 6) {
      await AuthCoordinator.instance.setLoggedIn(true);
      return true;
    }
    return false;
  }
}
