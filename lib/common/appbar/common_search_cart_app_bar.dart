import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/utils/platform_helper.dart';
import '../../common/buttons/cart_icon_button.dart';
import '../../common/searchbar/app_search_bar.dart';

class CommonSearchCartAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String searchHintText;
  final String? searchStaticPrefix;
  final List<String>? searchAnimatedHints;
  final ValueChanged<String>? onSearchChanged;
  final int currentBottomBarIndex;
  final bool showBackButton;
  final VoidCallback? onBackPress;

  const CommonSearchCartAppBar({
    super.key,
    required this.searchHintText,
    this.searchStaticPrefix,
    this.searchAnimatedHints,
    this.onSearchChanged,
    this.currentBottomBarIndex = 0,
    this.showBackButton = true,
    this.onBackPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final showBack = showBackButton && canPop;
    final backgroundColor = theme.scaffoldBackgroundColor;

    final searchBar = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: AppSearchBar(
        hintText: searchHintText,
        staticPrefix: searchStaticPrefix,
        animatedHints: searchAnimatedHints,
        onChanged: onSearchChanged,
      ),
    );

    if (PlatformHelper.isIOS) {
      return CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
        leading: showBack
            ? CupertinoNavigationBarBackButton(
                color: theme.primaryColor,
                onPressed: onBackPress ?? () => Navigator.of(context).pop(),
              )
            : null,
        middle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: searchBar,
        ),
        trailing: CartIconButton(currentBottomBarIndex: currentBottomBarIndex),
      );
    }

    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      toolbarHeight: 72,
      leading: showBack
          ? BackButton(
              onPressed: onBackPress ?? () => Navigator.of(context).pop(),
            )
          : null,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 4.0),
        child: Row(
          children: [
            Expanded(child: searchBar),
            const SizedBox(width: 12),
            CartIconButton(currentBottomBarIndex: currentBottomBarIndex),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(PlatformHelper.isIOS ? 44 : 72);
}
