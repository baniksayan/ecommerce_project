import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/wishlist_item_model.dart';
import '../../data/repositories/hive_wishlist_repository.dart';
import '../../data/repositories/wishlist_repository.dart';

/// Global coordinator for Wishlist state.
///
/// Keeps a central source of truth for wishlist items.
class WishlistCoordinator {
  WishlistCoordinator._();

  static final WishlistCoordinator instance = WishlistCoordinator._();

  final WishlistRepository _repository = HiveWishlistRepository();

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
  }

  Future<List<WishlistItemModel>> getItems() async {
    await init();
    return _repository.getItems();
  }

  Stream<List<WishlistItemModel>> watchItems() async* {
    await init();
    yield* _repository.watchItems();
  }

  Future<void> addItem(WishlistItemModel item) async {
    await init();
    await _repository.upsertItem(item);
  }

  Future<void> removeItem(String productId) async {
    await init();
    await _repository.removeItem(productId);
  }

  Future<void> clear() async {
    await init();
    await _repository.clear();
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _sub?.cancel();
    itemCount.dispose();
  }
}
