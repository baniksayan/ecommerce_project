import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item_model.dart';
import 'cart_repository.dart';

class HiveCartRepository implements CartRepository {
  Box<dynamic>? _box;

  @override
  Future<void> init() async {
    if (_box != null) return;
    _box = await Hive.openBox<dynamic>(CartRepositoryKeys.boxName);
  }

  Box<dynamic> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('CartRepository not initialized. Call init() first.');
    }
    return box;
  }

  @override
  Future<List<CartItemModel>> getItems() async {
    final raw = _requireBox.get(CartRepositoryKeys.kItems);
    if (raw is String) {
      return CartItemModel.decodeList(raw);
    }
    return const [];
  }

  Future<void> _saveItems(List<CartItemModel> items) async {
    await _requireBox.put(CartRepositoryKeys.kItems, CartItemModel.encodeList(items));
  }

  @override
  Stream<List<CartItemModel>> watchItems() async* {
    yield await getItems();
    yield* _requireBox
        .watch(key: CartRepositoryKeys.kItems)
        .asyncMap((_) => getItems());
  }

  @override
  Future<void> upsertItem(CartItemModel item) async {
    final items = [...await getItems()];
    final idx = items.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      final existing = items[idx];
      items[idx] = existing.copyWith(
        name: item.name,
        imageUrl: item.imageUrl,
        unitPrice: item.unitPrice,
        quantity: (existing.quantity + item.quantity).clamp(1, 999),
      );
    } else {
      items.insert(0, item.copyWith(quantity: item.quantity.clamp(1, 999)));
    }
    await _saveItems(items);
  }

  @override
  Future<void> setQuantity(String productId, int quantity) async {
    final items = [...await getItems()];
    final idx = items.indexWhere((e) => e.productId == productId);
    if (idx < 0) return;

    if (quantity <= 0) {
      items.removeAt(idx);
    } else {
      items[idx] = items[idx].copyWith(quantity: quantity.clamp(1, 999));
    }
    await _saveItems(items);
  }

  @override
  Future<void> removeItem(String productId) async {
    final items = (await getItems()).where((e) => e.productId != productId).toList();
    await _saveItems(items);
  }

  @override
  Future<void> clear() async {
    await _saveItems(const []);
  }
}

class CartRepositoryKeys {
  static const String boxName = 'cart_box';

  static const String kItems = 'items';
}
