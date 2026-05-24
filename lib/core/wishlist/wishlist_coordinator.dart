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

  bool get _hasSession =>
      AuthCoordinator.instance.hasActiveToken() ||
      AuthCoordinator.instance.currentUserId != null;

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
    final productId = int.tryParse(item.productId);
    if (!_hasSession) {
      return const WishlistActionResult(
        success: false,
        message: 'Please login first',
      );
    }

    if (productId != null) {
      bool localOnlySuccess = false;
      String? customMessage;
      try {
        final response = await _apiService.addToWishlist(productId: productId);
        if (response.success == true) {
          await _repository.upsertItem(item);
          try {
            await _syncFromServerIfPossible();
          } catch (_) {}
          
          return WishlistActionResult(
            success: true,
            message: (response.message ?? '').trim().isNotEmpty
                ? response.message!.trim()
                : 'Added to wishlist',
          );
        } else {
          customMessage = response.message;
        }
      } catch (_) {
        localOnlySuccess = true;
      }

      if (localOnlySuccess || customMessage == null) {
        await _repository.upsertItem(item);
        return const WishlistActionResult(
          success: true,
          message: 'Added to wishlist',
        );
      } else {
        return WishlistActionResult(
          success: false,
          message: customMessage.trim().isNotEmpty
              ? customMessage.trim()
              : 'Could not add to wishlist.',
        );
      }
    } else {
      // Mock item fallback (non-numeric product ID)
      await _repository.upsertItem(item);
      return const WishlistActionResult(
        success: true,
        message: 'Added to wishlist',
      );
    }
  }

  Future<WishlistActionResult> removeItem(String productId) async {
    await init();

    final numericProductId = int.tryParse(productId);
    if (!_hasSession) {
      return const WishlistActionResult(
        success: false,
        message: 'Please login first',
      );
    }

    if (numericProductId != null) {
      bool localOnlySuccess = false;
      String? customMessage;
      try {
        final response = await _apiService.removeFromWishlist(
          productId: numericProductId,
        );
        if (response.success == true) {
          await _repository.removeItem(productId);
          try {
            await _syncFromServerIfPossible();
          } catch (_) {}
          
          return const WishlistActionResult(
            success: true,
            message: 'Removed from wishlist',
          );
        } else {
          customMessage = response.message;
        }
      } catch (_) {
        localOnlySuccess = true;
      }

      if (localOnlySuccess || customMessage == null) {
        await _repository.removeItem(productId);
        return const WishlistActionResult(
          success: true,
          message: 'Removed from wishlist',
        );
      } else {
        return WishlistActionResult(
          success: false,
          message: customMessage.trim().isNotEmpty
              ? customMessage.trim()
              : 'Could not remove wishlist item.',
        );
      }
    } else {
      // Mock item fallback
      await _repository.removeItem(productId);
      return const WishlistActionResult(
        success: true,
        message: 'Removed from wishlist',
      );
    }
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

    if (!AuthCoordinator.instance.isLoggedIn || !_hasSession) {
      await _repository.clear();
      return const WishlistActionResult(
        success: false,
        message: 'Please login first',
      );
    }

    try {
      final response = await _apiService.getWishlist();
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
        // Preserve local wishlist when server database returns empty.
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

      // Preserve local wishlist modifications and merge server items.
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
