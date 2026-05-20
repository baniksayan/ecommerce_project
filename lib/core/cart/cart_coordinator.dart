import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_coordinator.dart';
import '../../core/utils/platform_helper.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/hive_cart_repository.dart';
import '../../models/cart_detail_model.dart';
import '../../services/api_service.dart';
import '../../views/cart/cart_view.dart';

/// Global coordinator for Cart state.
///
/// Keeps app bars in sync (badge count) and centralizes navigation to Cart.
/// View/UI layers can later swap the repository (API) without changing widgets.
class CartCoordinator {
  CartCoordinator._();

  static final CartCoordinator instance = CartCoordinator._();

  final CartRepository _repository = HiveCartRepository();
  final ApiService _apiService = ApiService();
  StreamSubscription<List<CartItemModel>>? _sub;

  final ValueNotifier<int> itemCount = ValueNotifier<int>(0);
  final ValueNotifier<double> subtotal = ValueNotifier<double>(0.0);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _repository.init();

    _sub?.cancel();
    _sub = _repository.watchItems().listen((items) {
      final count = items.fold<int>(0, (sum, e) => sum + e.quantity);
      itemCount.value = count;

      final nextSubtotal = items.fold<double>(
        0.0,
        (sum, e) => sum + (e.unitPrice * e.quantity),
      );
      subtotal.value = nextSubtotal;
    });

    await _syncFromServerIfPossible();
  }

  Future<void> addItem(CartItemModel item) async {
    await init();
    await _repository.upsertItem(item);
    await _syncAddToServer(item);
  }

  Future<void> setQuantity(String productId, int quantity) async {
    await init();
    await _repository.setQuantity(productId, quantity);

    final numericProductId = int.tryParse(productId);
    final userId = AuthCoordinator.instance.currentUserId;
    if (userId != null && numericProductId != null) {
      try {
        await _apiService.addToCart(
          userId: userId,
          productId: numericProductId,
          quantity: quantity,
        );
      } catch (_) {
        // Keep local cart responsive even when remote sync fails.
      }
    }
  }

  Future<void> removeItem(String productId) async {
    await init();
    await _repository.removeItem(productId);

    final numericProductId = int.tryParse(productId);
    final userId = AuthCoordinator.instance.currentUserId;
    if (userId != null && numericProductId != null) {
      try {
        await _apiService.removeFromCart(
          userId: userId,
          productId: numericProductId,
        );
      } catch (_) {
        // Keep local cart responsive even when remote sync fails.
      }
    }
  }

  Future<void> clear() async {
    await init();
    await _repository.clear();

    final userId = AuthCoordinator.instance.currentUserId;
    if (userId != null) {
      try {
        await _apiService.clearCart(userId: userId);
      } catch (_) {
        // Keep local cart responsive even when remote sync fails.
      }
    }
  }

  Future<void> syncFromServer() async {
    await init();

    await _syncFromServerIfPossible();
  }

  Future<void> _syncFromServerIfPossible() async {
    if (!_initialized) {
      return;
    }

    if (!AuthCoordinator.instance.isLoggedIn) {
      return;
    }

    final userId = AuthCoordinator.instance.currentUserId;
    if (userId == null) {
      return;
    }

    try {
      final response = await _apiService.getCartDetail(userId: userId);
      final items = response.data?.items ?? <CartDetailItem>[];

      await _repository.clear();
      for (final item in items) {
        final productId = item.productId?.toString();
        final name = (item.name ?? '').trim();
        final price = double.tryParse((item.price ?? '').toString()) ?? 0.0;
        final quantity = item.quantity ?? 1;

        if (productId == null || productId.isEmpty || name.isEmpty) {
          continue;
        }

        await _repository.upsertItem(
          CartItemModel(
            productId: productId,
            name: name,
            imageUrl: item.images,
            unitPrice: price,
            quantity: quantity,
          ),
        );
      }
    } catch (_) {
      // Do not interrupt app flow for sync failures.
    }
  }

  Future<void> _syncAddToServer(CartItemModel item) async {
    final userId = AuthCoordinator.instance.currentUserId;
    final productId = int.tryParse(item.productId);

    if (userId == null || productId == null) {
      return;
    }

    try {
      await _apiService.addToCart(
        userId: userId,
        productId: productId,
        quantity: item.quantity,
      );
    } catch (_) {
      // Keep local cart responsive even when remote sync fails.
    }
  }

  Future<List<CartItemModel>> getItems() async {
    await init();
    return _repository.getItems();
  }

  Stream<List<CartItemModel>> watchItems() async* {
    await init();
    yield* _repository.watchItems();
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
    subtotal.dispose();
  }
}
