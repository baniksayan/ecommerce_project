import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/auth/auth_coordinator.dart';
import '../../core/utils/platform_helper.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../data/repositories/hive_cart_repository.dart';
import '../../models/cart_add_model.dart';
import '../../models/cart_detail_model.dart';
import '../../services/api_service.dart';
import '../../views/cart/cart_view.dart';

class CartActionResult {
  final bool success;
  final String message;

  const CartActionResult({required this.success, required this.message});
}

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

  bool get _hasSession =>
      AuthCoordinator.instance.hasActiveToken() ||
      AuthCoordinator.instance.currentUserId != null;

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

  Future<CartActionResult> addItem(CartItemModel item) async {
    await init();

    final productId = int.tryParse(item.productId.trim());
    final safeQuantity = item.quantity.clamp(1, 999);
    if (!_hasSession) {
      return const CartActionResult(
        success: false,
        message: 'Please login first',
      );
    }
    if (productId == null) {
      return CartActionResult(
        success: false,
        message:
            'Could not add to cart. Product ID: ${item.productId.trim()}, Qty: $safeQuantity',
      );
    }

    Cartadd? response;
    try {
      response = await _apiService.addToCart(
        productId: productId,
        quantity: safeQuantity,
        productName: item.name,
      );
    } on ApiServiceException catch (e) {
      return CartActionResult(
        success: false,
        message:
            'Add to cart failed for product_id=$productId, quantity=$safeQuantity. Server says: ${e.message}',
      );
    } catch (_) {
      return CartActionResult(
        success: false,
        message:
            'Add to cart failed for product_id=$productId, quantity=$safeQuantity. Please try again.',
      );
    }

    try {
      await _syncFromServerIfPossible();
    } catch (_) {
      // Add request already succeeded; ignore sync errors for user feedback.
    }

    if (response.success == true) {
      return CartActionResult(
        success: true,
        message: (response.message ?? '').trim().isNotEmpty
            ? response.message!.trim()
            : 'Added to cart',
      );
    }

    final serverMessage = (response.message ?? '').trim().isNotEmpty
        ? response.message!.trim()
        : 'Unknown server error';
    return CartActionResult(
      success: false,
      message:
          'Add to cart failed for product_id=$productId, quantity=$safeQuantity. Server says: $serverMessage',
    );
  }

  Future<void> setQuantity(String productId, int quantity) async {
    await init();
    final numericProductId = int.tryParse(productId.trim());
    final safeQuantity = quantity.clamp(1, 999);
    if (_hasSession && numericProductId != null) {
      try {
        await _apiService.addToCart(
          productId: numericProductId,
          quantity: safeQuantity,
        );
        await _syncFromServerIfPossible();
      } catch (_) {
        // Keep previous mirrored state when remote sync fails.
      }
    }
  }

  Future<void> removeItem(String productId) async {
    await init();
    final numericProductId = int.tryParse(productId.trim());
    if (_hasSession && numericProductId != null) {
      try {
        await _apiService.removeFromCart(productId: numericProductId);
        await _syncFromServerIfPossible();
      } catch (_) {
        // Keep previous mirrored state when remote sync fails.
      }
    }
  }

  Future<void> clear() async {
    await init();
    if (_hasSession) {
      try {
        await _apiService.clearCart();
        await _syncFromServerIfPossible();
      } catch (_) {
        // Keep previous mirrored state when remote sync fails.
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

    if (!AuthCoordinator.instance.isLoggedIn || !_hasSession) {
      await _repository.clear();
      return;
    }

    try {
      final response = await _apiService.getCartDetail();
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
