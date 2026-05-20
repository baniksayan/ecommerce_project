import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/auth/auth_coordinator.dart';
import '../../services/api_service.dart';
import '../../data/models/wishlist_item_model.dart';
import '../../data/repositories/hive_wishlist_repository.dart';
import '../../data/repositories/wishlist_repository.dart';

class WishlistActionResult {
  final bool success;
  final String message;

  const WishlistActionResult({required this.success, required this.message});
}

/// Global coordinator for Wishlist state.
///
/// Keeps a central source of truth for wishlist items.
class WishlistCoordinator {
  WishlistCoordinator._();

  static final WishlistCoordinator instance = WishlistCoordinator._();

  final WishlistRepository _repository = HiveWishlistRepository();
  final ApiService _apiService = ApiService();

  StreamSubscription<List<WishlistItemModel>>? _sub;

  final ValueNotifier<int> itemCount = ValueNotifier<int>(0);

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await _repository.init();

    _sub?.cancel();
    _sub = _repository.watchItems().listen((items) {
      itemCount.value = items.length;
    });

    await _syncFromServerIfPossible();
  }

  Future<List<WishlistItemModel>> getItems() async {
    await init();
    return _repository.getItems();
  }

  Stream<List<WishlistItemModel>> watchItems() async* {
    await init();
    yield* _repository.watchItems();
  }

  Future<WishlistActionResult> addItem(WishlistItemModel item) async {
    await init();
    await _repository.upsertItem(item);

    final userId = AuthCoordinator.instance.currentUserId;
    final productId = int.tryParse(item.productId);
    if (userId != null && productId != null) {
      try {
        final response = await _apiService.addToWishlist(
          userId: userId,
          productId: productId,
        );
        return WishlistActionResult(
          success: response.success == true,
          message: (response.message ?? '').trim().isNotEmpty
              ? response.message!.trim()
              : 'Added to wishlist',
        );
      } catch (_) {
        // Keep local wishlist responsive even when remote sync fails.
        return const WishlistActionResult(
          success: false,
          message: 'Added locally. Server sync failed.',
        );
      }
    }

    return const WishlistActionResult(
      success: true,
      message: 'Added to wishlist',
    );
  }

  Future<WishlistActionResult> removeItem(String productId) async {
    await init();

    final userId = AuthCoordinator.instance.currentUserId;
    final numericProductId = int.tryParse(productId);
    if (userId != null && numericProductId != null) {
      try {
        final response = await _apiService.removeFromWishlist(
          userId: userId,
          productId: numericProductId,
        );
        if (response.success != true) {
          return WishlistActionResult(
            success: false,
            message: (response.message ?? '').trim().isNotEmpty
                ? response.message!.trim()
                : 'Could not remove wishlist item.',
          );
        }
      } catch (_) {
        // Keep local wishlist responsive even when remote sync fails.
        return const WishlistActionResult(
          success: false,
          message: 'Failed to remove item from server.',
        );
      }
    }

    await _repository.removeItem(productId);
    return const WishlistActionResult(
      success: true,
      message: 'Removed from wishlist',
    );
  }

  Future<void> clear() async {
    await init();
    await _repository.clear();
  }

  Future<WishlistActionResult> syncFromServer() async {
    await init();
    return _syncFromServerIfPossible();
  }

  Future<WishlistActionResult> _syncFromServerIfPossible() async {
    if (!_initialized) {
      return const WishlistActionResult(success: true, message: '');
    }

    if (!AuthCoordinator.instance.isLoggedIn) {
      return const WishlistActionResult(
        success: false,
        message: 'Please login first',
      );
    }

    final userId = AuthCoordinator.instance.currentUserId;
    if (userId == null) {
      return const WishlistActionResult(
        success: false,
        message: 'User session not ready. Please login again.',
      );
    }

    try {
      final response = await _apiService.getWishlist(userId: userId);
      if (response.success != true) {
        // Keep the last valid local state when server reports failure.
        return WishlistActionResult(
          success: false,
          message: 'Failed to sync wishlist from server.',
        );
      }

      final apiItems = response.data?.items;
      if (apiItems == null) {
        // Invalid payload; do not wipe local items.
        return const WishlistActionResult(
          success: false,
          message: 'Invalid wishlist response from server.',
        );
      }

      if (apiItems.isEmpty) {
        // Never clear local wishlist on page-open sync.
        // Empty server payload should not delete locally saved items.
        return const WishlistActionResult(success: true, message: '');
      }

      final mapped = <WishlistItemModel>[];
      for (final item in apiItems) {
        final productId = item.productId?.toString();
        final name = (item.name ?? '').trim();
        final price = double.tryParse((item.price ?? '').toString()) ?? 0.0;

        if (productId == null || productId.isEmpty) {
          continue;
        }

        mapped.add(
          WishlistItemModel(
            productId: productId,
            name: name.isEmpty ? 'Unnamed Product' : name,
            imageUrl: item.images,
            sku: item.sku,
            unitPrice: price,
          ),
        );
      }

      if (mapped.isEmpty) {
        // Parsed nothing useful from a non-empty API payload; preserve local.
        return const WishlistActionResult(
          success: false,
          message: 'Could not parse wishlist items from server.',
        );
      }

      for (final item in mapped) {
        await _repository.upsertItem(item);
      }
      return const WishlistActionResult(success: true, message: '');
    } catch (_) {
      // Do not interrupt app flow for sync failures.
      return const WishlistActionResult(
        success: false,
        message: 'Wishlist sync failed. Showing last saved data.',
      );
    }
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _sub?.cancel();
    itemCount.dispose();
  }
}
