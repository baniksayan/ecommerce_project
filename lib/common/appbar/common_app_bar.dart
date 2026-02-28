import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';
import '../../core/theme/app_text_styles.dart';

/// Unifies AppBar creation preventing repetitive code across screens.
/// Adapts to iOS (CupertinoNavigationBar) and Android (AppBar).
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final Widget? trailing;
  final Widget? leading;

  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPress,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showBack = showBackButton && canPop;
    final backgroundColor = theme.scaffoldBackgroundColor;

    if (PlatformHelper.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        leading:
            leading ??
            (showBack
                ? CupertinoNavigationBarBackButton(
                    color: theme.primaryColor,
                    onPressed: onBackPress ?? () => Navigator.of(context).pop(),
                  )
                : null),
        trailing: trailing,
      );
    } else {
      return AppBar(
        title: Text(title, style: AppTextStyles.heading2),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading:
            leading ??
            (showBack
                ? BackButton(
                    onPressed: onBackPress ?? () => Navigator.of(context).pop(),
                  )
                : null),
        actions: trailing != null ? [trailing!] : actions,
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
