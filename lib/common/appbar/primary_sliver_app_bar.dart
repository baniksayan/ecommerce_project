import 'package:flutter/material.dart';
import '../searchbar/app_search_bar.dart';
import '../buttons/cart_icon_button.dart';

class PrimarySliverAppBar extends StatelessWidget {
  final String searchHintText;
  final String? searchStaticPrefix;
  final List<String>? searchAnimatedHints;
  final ValueChanged<String>? onSearchChanged;
  final int? cartItemCount;
  final int currentBottomBarIndex;

  const PrimarySliverAppBar({
    super.key,
    required this.searchHintText,
    this.searchStaticPrefix,
    this.searchAnimatedHints,
    this.onSearchChanged,
    this.cartItemCount,
    this.currentBottomBarIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.98),
      elevation: 0,
      floating: true,
      pinned: false,
      toolbarHeight: 72,
      title: Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 4.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
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
              ),
            ),
            const SizedBox(width: 12),
            CartIconButton(currentBottomBarIndex: currentBottomBarIndex),
          ],
        ),
      ),
    );
  }
}
