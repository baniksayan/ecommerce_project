import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/utils/platform_helper.dart';

/// Reusable Tabs rendering Material TabBar on Android and Cupertino Segmented Control on iOS.
class CommonTabBar extends StatelessWidget {
  final List<String> tabs;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final TabController?
  tabController; // Required for Android Material swipe physics

  const CommonTabBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (PlatformHelper.isIOS) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: theme.colorScheme.surface,
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: currentIndex,
          onValueChanged: (int? value) {
            if (value != null) {
              onTabChanged(value);
              tabController?.animateTo(value);
            }
          },
          children: {
            for (int i = 0; i < tabs.length; i++)
              i: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: currentIndex == i
                        ? theme.colorScheme.onSurface
                        : theme.unselectedWidgetColor,
                    fontWeight: currentIndex == i
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
          },
        ),
      );
    } else {
      assert(tabController != null, 'Material TabBar requires a TabController');
      return Container(
        color: theme.colorScheme.surface,
        child: TabBar(
          controller: tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.unselectedWidgetColor,
          indicatorColor: theme.primaryColor,
          onTap: onTabChanged,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      );
    }
  }
}
