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
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.colorScheme.surface,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: theme.unselectedWidgetColor,
          showUnselectedLabels: true,
          elevation: 0,
          items: items.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: item.activeIcon != null
                  ? Icon(item.activeIcon)
                  : null,
              label: item.label,
            );
          }).toList(),
        ),
      );
    }
  }
}
