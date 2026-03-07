import 'dart:async';

import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/wishlist_item_model.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import 'base_viewmodel.dart';

class ProductDetailsViewModel extends BaseViewModel {
  final ProductModel product;
  final ProductRepository _productRepository;
  final CartRepository _cartRepository;
  final WishlistRepository _wishlistRepository;

  ProductDetailsViewModel({
    required this.product,
    required ProductRepository productRepository,
    required CartRepository cartRepository,
    required WishlistRepository wishlistRepository,
  }) : _productRepository = productRepository,
       _cartRepository = cartRepository,
       _wishlistRepository = wishlistRepository;

  StreamSubscription<List<CartItemModel>>? _cartSub;
  StreamSubscription<List<WishlistItemModel>>? _wishlistSub;

  int _quantity = 1;
  int get quantity => _quantity;

  int _cartQuantity = 0;
  int get cartQuantity => _cartQuantity;
  bool get isInCart => _cartQuantity > 0;

  bool _isWishlisted = false;
  bool get isWishlisted => _isWishlisted;

  List<String> _imageUrls = const [];
  List<String> get imageUrls => _imageUrls;

  List<ProductModel> _similarProducts = const [];
  List<ProductModel> get similarProducts => _similarProducts;

  List<ProductModel> _recommendedProducts = const [];
  List<ProductModel> get recommendedProducts => _recommendedProducts;

  List<ProductModel> _categorySearchProducts = const [];
  List<ProductModel> get categorySearchProducts => _categorySearchProducts;

  String get productDescription {
    // Static placeholder (API-ready): keep the UI independent of content source.
    return 'Fresh ${product.name.toLowerCase()} sourced locally.\n'
        'Pack size: 1 unit.\n'
        'Category: ${product.category.displayName}.';
  }

  Future<void> init() async {
    if (isLoading) return;

    setLoading(true);
    clearError();

    try {
      _imageUrls = [product.imageUrl];

      await Future.wait([_cartRepository.init(), _wishlistRepository.init()]);

      _syncCartSnapshot(await _cartRepository.getItems());
      _syncWishlistSnapshot(await _wishlistRepository.getItems());

      _cartSub?.cancel();
      _cartSub = _cartRepository.watchItems().listen(_syncCartSnapshot);

      _wishlistSub?.cancel();
      _wishlistSub = _wishlistRepository.watchItems().listen(
        _syncWishlistSnapshot,
      );

      final all = await _productRepository.getProducts(product.category);
      _similarProducts = all
          .where((p) => p.id != product.id)
          .take(6)
          .toList(growable: false);

      // Recommended — products from the next category in the enum ring
      final allCategories = ProductCategory.values;
      final nextCat =
          allCategories[(product.category.index + 1) % allCategories.length];
      final recommended = await _productRepository.getProducts(nextCat);
      _recommendedProducts = recommended.take(6).toList(growable: false);

      // Because you searched — full same-category catalog, exclude current
      _categorySearchProducts = all
          .where((p) => p.id != product.id)
          .toList(growable: false);
    } catch (_) {
      setError('Failed to load product.');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void _syncCartSnapshot(List<CartItemModel> items) {
    final match = items.cast<CartItemModel?>().firstWhere(
      (e) => e?.productId == product.id,
      orElse: () => null,
    );

    final nextCartQty = match?.quantity ?? 0;
    if (_cartQuantity != nextCartQty) {
      _cartQuantity = nextCartQty;
    }

    final targetQty = (_cartQuantity > 0 ? _cartQuantity : _quantity).clamp(
      1,
      999,
    );
    if (_quantity != targetQty) {
      _quantity = targetQty;
    }

    notifyListeners();
  }

  void _syncWishlistSnapshot(List<WishlistItemModel> items) {
    final next = items.any((e) => e.productId == product.id);
    if (_isWishlisted != next) {
      _isWishlisted = next;
      notifyListeners();
    }
  }

  void setQuantity(int value) {
    final next = value.clamp(1, 999);
    if (_quantity == next) return;
    _quantity = next;
    notifyListeners();
  }

  Future<void> incrementQuantity() async {
    setQuantity(_quantity + 1);
    if (isInCart) {
      await _cartRepository.setQuantity(product.id, _quantity);
    }
  }

  Future<void> decrementQuantity() async {
    if (_quantity <= 1) return;
    setQuantity(_quantity - 1);
    if (isInCart) {
      await _cartRepository.setQuantity(product.id, _quantity);
    }
  }

  Future<void> addToCart() async {
    await _cartRepository.upsertItem(
      CartItemModel(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        unitPrice: product.price,
        quantity: _quantity,
      ),
    );
  }

  Future<void> addProductToCart(ProductModel p, {int quantity = 1}) async {
    await _cartRepository.upsertItem(
      CartItemModel(
        productId: p.id,
        name: p.name,
        imageUrl: p.imageUrl,
        unitPrice: p.price,
        quantity: quantity.clamp(1, 999),
      ),
    );
  }

  Future<void> toggleWishlist() async {
    if (_isWishlisted) {
      await _wishlistRepository.removeItem(product.id);
      return;
    }

    await _wishlistRepository.upsertItem(
      WishlistItemModel(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        unitPrice: product.price,
      ),
    );
  }

  @override
  void dispose() {
    _cartSub?.cancel();
    _wishlistSub?.cancel();
    super.dispose();
  }
}
