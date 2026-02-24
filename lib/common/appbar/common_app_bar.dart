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
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPress,
    this.trailing,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showBack = showBackButton && canPop;

    if (PlatformHelper.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(
          title,
          style: AppTextStyles.heading3.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        leading:
            leading ??
            (showBack
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.back, color: theme.primaryColor),
                    onPressed: onBackPress ?? () => Navigator.of(context).pop(),
                  )
                : null),
        trailing: trailing,
      );
    } else {
      return AppBar(
        title: Text(title, style: AppTextStyles.heading2),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading:
            leading ??
            (showBack
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
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
