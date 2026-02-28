import '../models/cart_item_model.dart';

/// Repository abstraction for cart operations.
///
/// UI/ViewModel depend only on this contract so the backing store can be
/// swapped (Hive today, API later) without changing screen logic.
abstract class CartRepository {
  Future<void> init();

  Future<List<CartItemModel>> getItems();

  /// Emits whenever cart items are updated.
  Stream<List<CartItemModel>> watchItems();

  Future<void> upsertItem(CartItemModel item);
  Future<void> setQuantity(String productId, int quantity);
  Future<void> removeItem(String productId);
  Future<void> clear();
}
