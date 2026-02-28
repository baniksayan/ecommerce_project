import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/wishlist_item_model.dart';
import 'wishlist_repository.dart';

class HiveWishlistRepository implements WishlistRepository {
  Box<dynamic>? _box;

  @override
  Future<void> init() async {
    if (_box != null) return;
    _box = await Hive.openBox<dynamic>(WishlistRepositoryKeys.boxName);
  }

  Box<dynamic> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError(
        'WishlistRepository not initialized. Call init() first.',
      );
    }
    return box;
  }

  @override
  Future<List<WishlistItemModel>> getItems() async {
    final raw = _requireBox.get(WishlistRepositoryKeys.kItems);
    if (raw is String) {
      return WishlistItemModel.decodeList(raw);
    }
    return const [];
  }

  Future<void> _saveItems(List<WishlistItemModel> items) async {
    await _requireBox.put(
      WishlistRepositoryKeys.kItems,
      WishlistItemModel.encodeList(items),
    );
  }

  @override
  Stream<List<WishlistItemModel>> watchItems() async* {
    yield await getItems();
    yield* _requireBox
        .watch(key: WishlistRepositoryKeys.kItems)
        .asyncMap((_) => getItems());
  }

  @override
  Future<void> upsertItem(WishlistItemModel item) async {
    final items = [...await getItems()];
    final idx = items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(
        name: item.name,
        imageUrl: item.imageUrl,
        unitPrice: item.unitPrice,
      );
    } else {
      items.insert(0, item);
    }
    await _saveItems(items);
  }

  @override
  Future<void> removeItem(String productId) async {
    final items = (await getItems())
        .where((e) => e.productId != productId)
        .toList(growable: false);
    await _saveItems(items);
  }

  @override
  Future<void> clear() async {
    await _saveItems(const []);
  }
}

class WishlistRepositoryKeys {
  static const String boxName = 'wishlist_box';

  static const String kItems = 'items';
}
