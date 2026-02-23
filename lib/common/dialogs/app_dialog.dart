import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';
import '../../core/theme/app_text_styles.dart';

/// Centralized Dialog system mapping standard alerts and confirm actions
/// natively to Android (Material) and iOS (Cupertino).
class AppDialog {
  /// General purpose show dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title, style: AppTextStyles.heading3),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: content,
          ),
          actions: actions,
        ),
      );
    } else {
      return showDialog<T>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title, style: AppTextStyles.heading3),
          content: content,
          actions: actions,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }

  /// Specialized showConfirm for straightforward Yes/No or Destructive tasks.
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  cancelText,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDestructive
                      ? theme.colorScheme.error
                      : theme.primaryColor,
                  foregroundColor: isDestructive
                      ? theme.colorScheme.onError
                      : theme.colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          );
        },
      );
    }
  }

  /// Simple Alert with an OK button.
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<void>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    } else {
      return showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(buttonText),
            ),
          ],
        ),
      );
    }
  }
}
