import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum SnackbarType { success, error, warning, info, destructive }

/// A reusable central Snackbar system mapping standard messages
/// with visual status indicators mapping to Enchanted Forest themes.
class AppSnackbar {
  static Color _getBgColor(BuildContext context, SnackbarType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case SnackbarType.success:
        return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
      case SnackbarType.error:
      case SnackbarType.destructive:
        return isDark ? AppColors.darkError : AppColors.lightError;
      case SnackbarType.warning:
        return isDark ? AppColors.darkWarning : AppColors.lightWarning;
      case SnackbarType.info:
        return isDark ? AppColors.darkInfo : AppColors.lightInfo;
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.error:
        return Icons.error;
      case SnackbarType.warning:
        return Icons.warning;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.destructive:
        return Icons.delete_forever;
    }
  }

  static void _show(
    BuildContext context,
    String message,
    SnackbarType type, {
    SnackBarAction? action,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_getIcon(type), color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: _getBgColor(context, type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
      action: action,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static void success(BuildContext context, String message) =>
      _show(context, message, SnackbarType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, SnackbarType.error);

  static void warning(BuildContext context, String message) =>
      _show(context, message, SnackbarType.warning);

  static void info(BuildContext context, String message) =>
      _show(context, message, SnackbarType.info);

  static void destructive(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) => _show(context, message, SnackbarType.destructive, action: action);
}
