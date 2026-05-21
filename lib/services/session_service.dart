import '../core/auth/auth_coordinator.dart';

class SessionService {
  SessionService._();

  static final SessionService instance = SessionService._();

  Future<void> loadSessionOnAppStart() async {
    await AuthCoordinator.instance.init();
  }

  Future<void> saveLoginSession({
    required int? userId,
    String? name,
    String? email,
    String? token,
  }) async {
    await AuthCoordinator.instance.setLoggedIn(
      (token ?? '').trim().isNotEmpty || userId != null,
    );
    await AuthCoordinator.instance.setUserSession(
      userId: userId,
      token: token,
      name: name,
      email: email,
    );
  }

  int? getCurrentUserId() => AuthCoordinator.instance.currentUserId;

  Map<String, dynamic> getCurrentUser() =>
      AuthCoordinator.instance.currentUserSnapshot;

  bool isLoggedIn() => AuthCoordinator.instance.isLoggedIn;

  Future<void> clearSession() async {
    await AuthCoordinator.instance.logout();
  }
}
