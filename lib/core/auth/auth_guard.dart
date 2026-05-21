import 'package:flutter/material.dart';

import '../../common/snackbars/app_snackbar.dart';
import '../../views/auth/email_login_view.dart';
import 'auth_coordinator.dart';

bool isUserLoggedIn() {
  return AuthCoordinator.instance.isLoggedIn;
}

bool isLoggedIn() {
  return isUserLoggedIn();
}

int? currentUserId() {
  return AuthCoordinator.instance.currentUserId;
}

Future<bool> handleProtectedAction(
  BuildContext context, {
  String message = 'Please login first',
}) async {
  final isLoggedIn = isUserLoggedIn();
  final hasToken = AuthCoordinator.instance.hasActiveToken();
  final hasUserId = AuthCoordinator.instance.currentUserId != null;

  if (isLoggedIn && (hasToken || hasUserId)) {
    return true;
  }

  AppSnackbar.warning(context, message);

  await Future<void>.delayed(const Duration(milliseconds: 220));
  if (!context.mounted) {
    return false;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const EmailLoginView(fromDrawer: true)),
  );

  return isUserLoggedIn() &&
      (AuthCoordinator.instance.hasActiveToken() ||
          AuthCoordinator.instance.currentUserId != null);
}
