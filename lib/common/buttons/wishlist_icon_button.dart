import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/auth/auth_guard.dart';
import '../../core/wishlist/wishlist_coordinator.dart';
import '../../views/main/main_view.dart';

class WishlistIconButton extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool enableNavigation;
  final int currentBottomBarIndex;

  const WishlistIconButton({
    super.key,
    this.margin,
    this.enableNavigation = true,
    this.currentBottomBarIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;

    return ValueListenableBuilder<int>(
      valueListenable: WishlistCoordinator.instance.itemCount,
      builder: (context, count, child) {
        final safeCount = count.clamp(0, 99);

        return Container(
          margin: margin,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Semantics(
                label: 'Wishlist, $count items',
                button: true,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.08),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.favorite_border, color: primary),
                    tooltip: 'Wishlist',
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      if (!enableNavigation) return;

                      final allowed = await handleProtectedAction(context);
                      if (!allowed || !context.mounted) return;

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MainView(initialIndex: 1),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (safeCount > 0)
                Positioned(
                  right: 4,
                  top: 6,
                  child: IgnorePointer(
                    child: Container(
                      width: 17,
                      height: 17,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$safeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
