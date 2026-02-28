import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/utils/platform_helper.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/hive_cart_repository.dart';
import '../../views/cart/cart_view.dart';

/// Global coordinator for Cart state.
///
/// Keeps app bars in sync (badge count) and centralizes navigation to Cart.
/// View/UI layers can later swap the repository (API) without changing widgets.
class CartCoordinator {
  CartCoordinator._();

  static final CartCoordinator instance = CartCoordinator._();

  final CartRepository _repository = HiveCartRepository();
  StreamSubscription<List<CartItemModel>>? _sub;

  final ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _repository.init();

    _sub?.cancel();
    _sub = _repository.watchItems().listen((items) {
      final count = items.fold<int>(0, (sum, e) => sum + e.quantity);
      itemCount.value = count;
    });
  }

  Future<void> addItem(CartItemModel item) async {
    await _repository.upsertItem(item);
  }

  void openCart(BuildContext context, {int currentBottomBarIndex = 0}) {
    final route = PlatformHelper.isIOS
        ? CupertinoPageRoute<void>(
            builder: (_) =>
                CartView(currentBottomBarIndex: currentBottomBarIndex),
          )
        : MaterialPageRoute<void>(
            builder: (_) =>
                CartView(currentBottomBarIndex: currentBottomBarIndex),
          );

    Navigator.of(context).push(route);
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _sub?.cancel();
    itemCount.dispose();
  }
}
