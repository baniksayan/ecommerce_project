import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline }

/// A unified, highly customizable Button resolving common states natively.
/// Ensures consistent heights, radii, and loading overlays.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outline({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
  }) : variant = AppButtonVariant.outline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Disable interaction if loading or explicitly disabled via null onPressed
    final bool isDisabled = onPressed == null || isLoading;
    final callback = isDisabled ? null : onPressed;

    final label = Text(
      text,
      style: AppTextStyles.button,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    // NOTE: Avoid LayoutBuilder here.
    // SliverFillRemaining(hasScrollBody: false) may compute intrinsic height,
    // and LayoutBuilder throws when asked for intrinsic dimensions.
    final Widget labelWidget = isFullWidth ? Flexible(child: label) : label;

    final Widget buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.primary
                    ? theme.colorScheme.onPrimary
                    : theme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        labelWidget,
      ],
    );

    // Apply specific widget based on variant
    Widget buttonWidget;

    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: isDisabled ? 0 : 2,
            disabledBackgroundColor: theme.disabledColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
          ),
          child: buttonContent,
        );
        break;
      case AppButtonVariant.secondary:
        buttonWidget = ElevatedButton(
          onPressed: callback,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            disabledBackgroundColor: theme.disabledColor.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
          ),
          child: buttonContent,
        );
        break;
      case AppButtonVariant.outline:
        buttonWidget = OutlinedButton(
          onPressed: callback,
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.primaryColor,
            side: BorderSide(
              color: isDisabled ? theme.disabledColor : theme.primaryColor,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(isFullWidth ? double.infinity : 0, 48),
          ),
          child: buttonContent,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }

    return buttonWidget;
  }
}
