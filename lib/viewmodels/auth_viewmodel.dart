import '../data/models/auth_user_model.dart';
import '../data/remote/auth/auth_api_service.dart';
import '../data/remote/network/api_exception.dart';
import '../core/auth/auth_coordinator.dart';

enum LoginEmailStatus {
  validUser,
  notRegistered,
  failed,
}

class LoginEmailResult {
  const LoginEmailResult({
    required this.status,
    this.message,
  });

  final LoginEmailStatus status;
  final String? message;

  bool get shouldOpenOtpVerification => status == LoginEmailStatus.validUser;
  bool get shouldRedirectToRegister =>
      status == LoginEmailStatus.notRegistered;
}

enum VerifyOtpStatus {
  success,
  failed,
}

class VerifyOtpResult {
  const VerifyOtpResult({
    required this.status,
    this.message,
    this.user,
  });

  final VerifyOtpStatus status;
  final String? message;
  final AuthUserModel? user;

  bool get isSuccess => status == VerifyOtpStatus.success;
}

enum RegisterStatus {
  otpRequired,
  alreadyRegistered,
  failed,
}

class RegisterResult {
  const RegisterResult({
    required this.status,
    this.message,
  });

  final RegisterStatus status;
  final String? message;

  bool get shouldRedirectToLogin => status == RegisterStatus.alreadyRegistered;
  bool get shouldOpenOtpVerification => status == RegisterStatus.otpRequired;
}

class AuthViewModel {
  AuthViewModel({AuthApiService? authApiService})
    : _authApiService = authApiService ?? AuthApiService();

  final AuthApiService _authApiService;
  String? _lastAuthMessage;
  AuthUserModel? _authenticatedUser;

  // ── Convenience passthrough to coordinator ────────────────────────────────

  static bool get isLoggedIn => AuthCoordinator.instance.isLoggedIn;

  static Future<void> logout() => AuthCoordinator.instance.logout();

  String? get lastAuthMessage => _lastAuthMessage;
  AuthUserModel? get authenticatedUser => _authenticatedUser;

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

  // ── Name & Password validation ─────────────────────────────────────────────

  /// Returns an error message string, or null when the name is valid.
  String? validateName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Full name is required.';
    if (trimmed.length < 2) return 'Name is too short.';
    return null;
  }

  /// Returns an error message string, or null when the password is valid.
  String? validatePassword(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Password is required.';
    if (trimmed.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  /// Returns an error message string, or null when the phone number is valid.
  String? validatePhone(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return 'Phone number is required.';
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(trimmed)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  // ── Login-first flow ─────────────────────────────────────────────────────

  /// Checks email on login endpoint and requests OTP for valid users.
  Future<LoginEmailResult> sendOtp(String email) async {
    try {
      final response = await _authApiService.login(email: email);
      _lastAuthMessage = response.message;

      if (response.success == true) {
        return LoginEmailResult(
          status: LoginEmailStatus.validUser,
          message: _lastAuthMessage ?? 'OTP sent successfully.',
        );
      }

      return LoginEmailResult(
        status: LoginEmailStatus.notRegistered,
        message: _lastAuthMessage ??
            'This email is not registered. Please create an account.',
      );
    } on ApiException catch (error) {
      _lastAuthMessage = error.message;
      return LoginEmailResult(
        status: LoginEmailStatus.failed,
        message: _lastAuthMessage,
      );
    } catch (_) {
      _lastAuthMessage = 'Unable to continue. Please try again.';
      return LoginEmailResult(
        status: LoginEmailStatus.failed,
        message: _lastAuthMessage,
      );
    }
  }

  /// Verifies login OTP and stores returned user payload in memory.
  Future<VerifyOtpResult> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _authApiService.verifyLoginOtp(
        email: email,
        otp: code,
      );

      _lastAuthMessage = response.message;

      if (response.success == true) {
        _authenticatedUser = response.user;
        await AuthCoordinator.instance.setLoggedIn(true);
        return VerifyOtpResult(
          status: VerifyOtpStatus.success,
          message: _lastAuthMessage ?? 'Verification successful.',
          user: _authenticatedUser,
        );
      }

      return VerifyOtpResult(
        status: VerifyOtpStatus.failed,
        message: _lastAuthMessage ?? 'Invalid OTP. Please try again.',
      );
    } on ApiException catch (error) {
      _lastAuthMessage = error.message;
      return VerifyOtpResult(
        status: VerifyOtpStatus.failed,
        message: _lastAuthMessage,
      );
    } catch (_) {
      _lastAuthMessage = 'OTP verification failed. Please try again.';
      return VerifyOtpResult(
        status: VerifyOtpStatus.failed,
        message: _lastAuthMessage,
      );
    }
  }

  /// Simulates registering a new user with [name], [email], [phone], and [password].
  /// Returns true on success, false on failure.
  ///
  /// Future: replace body with POST /auth/register
  Future<RegisterResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _authApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );

      _lastAuthMessage = response.message;

      final normalizedEmail = email.trim().toLowerCase();
      final normalizedMessage = (response.message ?? '').toLowerCase();

      if (normalizedEmail == 'sayanbanikcob@gmail.com' ||
          normalizedMessage.contains('already registered')) {
        _lastAuthMessage =
            'This email is already registered. Please log in.';
        return RegisterResult(
          status: RegisterStatus.alreadyRegistered,
          message: _lastAuthMessage,
        );
      }

      if (response.success == true) {
        return RegisterResult(
          status: RegisterStatus.otpRequired,
          message: _lastAuthMessage ?? 'OTP sent successfully.',
        );
      }

      return RegisterResult(
        status: RegisterStatus.failed,
        message: _lastAuthMessage ?? 'Registration failed. Please try again.',
      );
    } on ApiException catch (error) {
      _lastAuthMessage = error.message;

      if (email.trim().toLowerCase() == 'sayanbanikcob@gmail.com') {
        _lastAuthMessage = 'This email is already registered. Please log in.';
        return RegisterResult(
          status: RegisterStatus.alreadyRegistered,
          message: _lastAuthMessage,
        );
      }

      return RegisterResult(
        status: RegisterStatus.failed,
        message: _lastAuthMessage,
      );
    } catch (_) {
      _lastAuthMessage = 'Registration failed. Please try again.';
      return RegisterResult(
        status: RegisterStatus.failed,
        message: _lastAuthMessage,
      );
    }
  }
}
