import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/cart/cart_coordinator.dart';

class CartIconButton extends StatelessWidget {
  final EdgeInsetsGeometry? margin;
  final bool enableNavigation;
  final int currentBottomBarIndex;

  const CartIconButton({
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
      valueListenable: CartCoordinator.instance.itemCount,
      builder: (context, count, _) {
        final safeCount = count.clamp(0, 99);

        return Container(
          margin: margin,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Semantics(
                label: 'Cart, $count items',
                button: true,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withValues(alpha: 0.08),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.shopping_cart_outlined, color: primary),
                    tooltip: 'Cart',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      if (!enableNavigation) return;
                      CartCoordinator.instance.openCart(
                        context,
                        currentBottomBarIndex: currentBottomBarIndex,
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
