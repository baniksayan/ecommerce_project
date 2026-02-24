import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

class CommonBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  CommonBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// A centralized bottom navigation setup translating to Material and Cupertino natively.
class CommonBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CommonBottomBarItem> items;

  const CommonBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (PlatformHelper.isIOS) {
      return CupertinoTabBar(
        currentIndex: currentIndex,
        onTap: onTap,
        activeColor: theme.primaryColor,
        inactiveColor: theme.unselectedWidgetColor,
        backgroundColor: theme.colorScheme.surface,
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item.icon),
            activeIcon: item.activeIcon != null ? Icon(item.activeIcon) : null,
            label: item.label,
          );
        }).toList(),
      );
    } else {
      // Determine screen width for responsive sizing
      final double screenWidth = MediaQuery.of(context).size.width;
      final bool isLargeScreen = screenWidth > 600;

      // Control maximum width on very large screens to make it look elegant as a floating pill
      final double horizontalPadding = isLargeScreen
          ? (screenWidth * 0.15)
          : 24.0;
      final double verticalPadding = isLargeScreen ? 16.0 : 12.0;

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Container(
            decoration: BoxDecoration(
              // The user wants theme-based colors instead of hardcoded
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isSelected = index == currentIndex;

                return _BottomBarItemWidget(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  theme: theme,
                );
              }),
            ),
          ),
        ),
      );
    }
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  final CommonBottomBarItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _BottomBarItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine screen width for responsive sizing
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 600;

    // Dynamic sizing variables
    final double horizontalPadding = isLargeScreen
        ? (isSelected ? 32.0 : 24.0)
        : (isSelected ? 20.0 : 16.0);
    final double verticalPadding = isLargeScreen ? 16.0 : 12.0;
    final double iconSize = isLargeScreen ? 28.0 : 24.0;
    final double fontSize = isLargeScreen ? 16.0 : 14.0;

    // Unselected items can use theme.unselectedWidgetColor or similar
    final unselectedColor = theme.unselectedWidgetColor;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(isLargeScreen ? 40 : 30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected && item.activeIcon != null
                  ? item.activeIcon
                  : item.icon,
              color: isSelected ? theme.primaryColor : unselectedColor,
              size: iconSize,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
