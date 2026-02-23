import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ToastType { success, error, warning, info, loading }

/// A modern, reusable Toast system utilizing Flutter's Overlay mechanism.
/// Can be called from anywhere with a valid BuildContext.
class AppToast {
  static OverlayEntry? _currentToast;

  /// Private helper to get colors based on toast type
  static Color _getBgColor(BuildContext context, ToastType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case ToastType.success:
        return isDark ? AppColors.darkSuccess : AppColors.lightSuccess;
      case ToastType.error:
        return isDark ? AppColors.darkError : AppColors.lightError;
      case ToastType.warning:
        return isDark ? AppColors.darkWarning : AppColors.lightWarning;
      case ToastType.info:
      case ToastType.loading:
        return isDark ? AppColors.darkInfo : AppColors.lightInfo;
    }
  }

  static IconData _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline;
      case ToastType.error:
        return Icons.error_outline;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
      case ToastType.info:
      case ToastType.loading:
        return Icons.info_outline;
    }
  }

  static void _show(
    BuildContext context,
    String message,
    ToastType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    // Dismiss any existing toast
    _currentToast?.remove();

    final overlay = Overlay.of(context);

    // Create new toast entry
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBgColor(context, type),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (type == ToastType.loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  else
                    Icon(_getIcon(type), color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Insert toast into overlay
    overlay.insert(_currentToast!);

    // Schedule dismiss if not loading
    if (type != ToastType.loading) {
      Future.delayed(duration, () {
        if (_currentToast != null) {
          _currentToast!.remove();
          _currentToast = null;
        }
      });
    }
  }

  /// Manually dismiss current toast. Useful to clear `loading` toasts.
  static void dismiss() {
    _currentToast?.remove();
    _currentToast = null;
  }

  static void success(BuildContext context, String message) =>
      _show(context, message, ToastType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, ToastType.error);

  static void warning(BuildContext context, String message) =>
      _show(context, message, ToastType.warning);

  static void info(BuildContext context, String message) =>
      _show(context, message, ToastType.info);

  static void loading(BuildContext context, String message) =>
      _show(context, message, ToastType.loading);
}
