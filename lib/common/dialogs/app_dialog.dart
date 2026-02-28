import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';
import '../../core/theme/app_text_styles.dart';

/// Centralized Dialog system mapping standard alerts and confirm actions
/// natively to Android (Material) and iOS (Cupertino).
class AppDialog {
  static Widget _buildScrollableContent(BuildContext context, Widget child) {
    final size = MediaQuery.sizeOf(context);
    final maxHeight = size.height * 0.45;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.normal,
        ),
        child: child,
      ),
    );
  }

  static Widget _buildMessageText(BuildContext context, String message) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        textAlign: TextAlign.start,
        style: AppTextStyles.bodyMedium.copyWith(
          color: onSurface.withValues(alpha: 0.8),
          height: 1.4,
        ),
      ),
    );
  }

  /// General purpose show dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    required List<Widget> actions,
    bool barrierDismissible = true,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
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
        barrierDismissible: barrierDismissible,
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
    bool barrierDismissible = false,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title, style: AppTextStyles.heading3),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildScrollableContent(
              context,
              _buildMessageText(context, message),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: isDestructive,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              isDefaultAction: !isDestructive,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            scrollable: true,
            title: Text(title, style: AppTextStyles.heading3),
            content: _buildMessageText(context, message),
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
    bool barrierDismissible = true,
  }) {
    if (PlatformHelper.isIOS) {
      return showCupertinoDialog<void>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title, style: AppTextStyles.heading3),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: _buildScrollableContent(
              context,
              _buildMessageText(context, message),
            ),
          ),
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
        barrierDismissible: barrierDismissible,
        builder: (context) => AlertDialog(
          scrollable: true,
          title: Text(title, style: AppTextStyles.heading3),
          content: _buildMessageText(context, message),
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
