import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/dialogs/app_dialog.dart';
import '../../common/snackbars/app_snackbar.dart';

class AppPermissionCoordinator {
  AppPermissionCoordinator._();

  static final AppPermissionCoordinator instance = AppPermissionCoordinator._();

  static const String _boxName = 'app_permissions_v1';
  static const String _firstLaunchPromptCompleted =
      'first_launch_prompt_completed';

  Box<dynamic>? _box;

  Future<void> init() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> requestPermissionsOnFirstLaunch(BuildContext context) async {
    await init();
    final alreadyRequested =
        (_box!.get(_firstLaunchPromptCompleted) as bool?) ?? false;
    if (alreadyRequested) return;

    // Browser permissions are requested ad-hoc by feature use;
    // avoid unsupported/global startup prompts on web.
    if (kIsWeb) {
      await _box!.put(_firstLaunchPromptCompleted, true);
      return;
    }

    try {
      final statuses = await _requestAllConfiguredPermissions();
      final deniedCount = statuses.values.where(_isDeniedLike).length;

      if (!context.mounted) return;
      if (deniedCount == 0) {
        AppSnackbar.success(context, 'Permissions granted successfully.');
        return;
      }

      final permanentlyDenied = statuses.values.any(
        (s) => s.isPermanentlyDenied,
      );

      if (permanentlyDenied) {
        final openSettings = await AppDialog.showConfirm(
          context: context,
          title: 'Permissions Needed',
          message:
              'Some permissions were permanently denied. You can continue, but features like live tracking, notifications, uploads, and calls may be limited. Open app settings now?',
          confirmText: 'Open Settings',
          cancelText: 'Continue',
        );

        if (openSettings == true) {
          await openAppSettings();
        }
      } else {
        AppSnackbar.warning(
          context,
          'Some permissions were denied. The app will continue with limited features.',
        );
      }
    } finally {
      await _box!.put(_firstLaunchPromptCompleted, true);
    }
  }

  Future<Map<String, PermissionStatus>> _requestAllConfiguredPermissions() async {
    final result = <String, PermissionStatus>{};

    final locationWhenInUse = await Permission.locationWhenInUse.request();
    result['location_when_in_use'] = locationWhenInUse;

    if (locationWhenInUse.isGranted || locationWhenInUse.isLimited) {
      result['background_location'] = await Permission.locationAlways.request();
    } else {
      result['background_location'] = PermissionStatus.denied;
    }

    result['notifications'] = await Permission.notification.request();
    result['microphone'] = await Permission.microphone.request();
    result['photos_media'] = await Permission.photos.request();

    if (defaultTargetPlatform != TargetPlatform.iOS) {
      result['phone'] = await Permission.phone.request();
    }

    return result;
  }

  bool _isDeniedLike(PermissionStatus status) {
    return status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied ||
        status == PermissionStatus.restricted;
  }
}
