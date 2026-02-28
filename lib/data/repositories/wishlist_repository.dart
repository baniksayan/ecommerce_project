import '../models/wishlist_item_model.dart';

/// Repository abstraction for wishlist operations.
abstract class WishlistRepository {
  Future<void> init();

  Future<List<WishlistItemModel>> getItems();

  /// Emits whenever wishlist items are updated.
  Stream<List<WishlistItemModel>> watchItems();

  Future<void> upsertItem(WishlistItemModel item);
  Future<void> removeItem(String productId);
  Future<void> clear();
}
