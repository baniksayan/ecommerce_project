import 'dart:async';

import '../data/models/cart_item_model.dart';
import '../data/models/product_model.dart';
import '../data/models/wishlist_item_model.dart';
import '../core/cart/cart_coordinator.dart';
import '../models/product_list_model.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import '../core/wishlist/wishlist_coordinator.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

class ProductDetailsViewModel extends BaseViewModel {
  final ProductModel product;
  final CartRepository _cartRepository;
  final WishlistRepository _wishlistRepository;
  final ApiService _apiService = ApiService();

  ProductDetailsViewModel({
    required this.product,
    required CartRepository cartRepository,
    required WishlistRepository wishlistRepository,
  }) : _cartRepository = cartRepository,
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

  String? _apiName;
  String? _apiCategoryLabel;
  double? _apiPrice;
  double? _apiOriginalPrice;
  int? _apiStockLeft;

  String get displayName =>
      (_apiName ?? '').trim().isNotEmpty ? _apiName!.trim() : product.name;

  String get displayCategoryLabel => (_apiCategoryLabel ?? '').trim().isNotEmpty
      ? _apiCategoryLabel!.trim()
      : product.category.displayName;

  double get displayPrice => _apiPrice ?? product.price;
  double? get displayOriginalPrice =>
      _apiOriginalPrice ?? product.originalPrice;
  int? get displayStockLeft => _apiStockLeft ?? product.stockLeft;

  String? get displayDiscountTag {
    if (displayOriginalPrice != null && displayOriginalPrice! > displayPrice) {
      final off =
          ((displayOriginalPrice! - displayPrice) / displayOriginalPrice! * 100)
              .round();
      if (off > 0) {
        return '$off% OFF';
      }
    }
    return product.discountTag;
  }

  String get productDescription {
    if ((_apiDescription ?? '').trim().isNotEmpty) {
      return _apiDescription!.trim();
    }
    return 'No description available.';
  }

  String? _apiDescription;

  Future<void> init() async {
    if (isLoading) return;

    setLoading(true);
    clearError();

    try {
      _imageUrls = product.imageUrl.trim().isNotEmpty
          ? <String>[product.imageUrl]
          : const <String>[];

      await Future.wait([_cartRepository.init(), _wishlistRepository.init()]);

      _syncCartSnapshot(await _cartRepository.getItems());
      _syncWishlistSnapshot(await _wishlistRepository.getItems());

      _cartSub?.cancel();
      _cartSub = _cartRepository.watchItems().listen(_syncCartSnapshot);

      _wishlistSub?.cancel();
      _wishlistSub = _wishlistRepository.watchItems().listen(
        _syncWishlistSnapshot,
      );

      _similarProducts = const <ProductModel>[];
      _recommendedProducts = const <ProductModel>[];
      _categorySearchProducts = const <ProductModel>[];

      await _hydrateFromApi();
    } catch (_) {
      setError('Failed to load product.');
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> _hydrateFromApi() async {
    final productId = int.tryParse(product.id);
    if (productId == null) return;

    try {
      final detail = await _apiService.getProductDetails(productId);
      final detailData = detail.data;

      if (detailData != null) {
        final images = (detailData.images ?? const <String>[])
            .map(_apiService.resolveImageUrl)
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);
        if (images.isNotEmpty) {
          _imageUrls = images;
        }

        if ((detailData.name ?? '').trim().isNotEmpty) {
          _apiName = detailData.name;
        }
        if ((detailData.categoryName ?? '').trim().isNotEmpty) {
          _apiCategoryLabel = detailData.categoryName;
        }
        if ((detailData.description ?? '').trim().isNotEmpty) {
          _apiDescription = detailData.description;
        }

        final base = double.tryParse(
          (detailData.price ?? '').toString().trim(),
        );
        final discount = double.tryParse(
          (detailData.discountPrice ?? '').toString().trim(),
        );

        if (base != null) {
          if (discount != null && discount > 0 && discount < base) {
            _apiPrice = discount;
            _apiOriginalPrice = base;
          } else {
            _apiPrice = base;
            _apiOriginalPrice = null;
          }
        }

        _apiStockLeft = detailData.stockQuantity ?? detailData.stock;
      }

      final list = await _apiService.getProducts();
      final apiAll = (list.data ?? const <ProductItemModel>[])
          .asMap()
          .entries
          .map((entry) => _mapApiProduct(entry.value, entry.key))
          .toList(growable: false);

      final sameCategory = apiAll
          .where((p) {
            final cat = p.category.displayName.toLowerCase();
            final current = displayCategoryLabel.toLowerCase();
            return cat == current && p.id != product.id;
          })
          .toList(growable: false);

      if (sameCategory.isNotEmpty) {
        _similarProducts = sameCategory.take(6).toList(growable: false);
        _categorySearchProducts = sameCategory;
      }

      if (apiAll.isNotEmpty) {
        _recommendedProducts = apiAll
            .where((p) => p.id != product.id)
            .take(6)
            .toList(growable: false);
      }
    } catch (_) {
      // Keep static fallback data if API fails.
    }
  }

  ProductModel _mapApiProduct(ProductItemModel item, int index) {
    final id = item.id?.toString() ?? 'detail-api-$index';
    final price = double.tryParse((item.price ?? '').trim()) ?? 0.0;

    return ProductModel(
      id: id,
      category: _categoryFromApiName(item.categoryName),
      name: (item.name ?? '').trim().isEmpty
          ? 'Product ${index + 1}'
          : item.name!.trim(),
      imageUrl: _apiService.resolveImageUrl(item.images),
      price: price,
      originalPrice: null,
      discountTag: null,
      rating: null,
      reviewCount: null,
      reviews: const [],
      stockLeft: null,
      isFastDelivery: null,
      isBestSeller: null,
    );
  }

  ProductCategory _categoryFromApiName(String? categoryName) {
    final value = (categoryName ?? '').toLowerCase();
    if (value.contains('beauty')) return ProductCategory.beauty;
    if (value.contains('shoe') || value.contains('footwear')) {
      return ProductCategory.shoes;
    }
    if (value.contains('fresh') || value.contains('vegetable')) {
      return ProductCategory.fresh;
    }
    if (value.contains('snack')) return ProductCategory.snacks;
    if (value.contains('drink') || value.contains('beverage')) {
      return ProductCategory.drinks;
    }
    if (value.contains('dairy')) return ProductCategory.dairy;
    if (value.contains('paan') || value.contains('tobacco')) {
      return ProductCategory.tobacco;
    }
    return ProductCategory.grocery;
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

  Future<CartActionResult> addToCart() async {
    return CartCoordinator.instance.addItem(
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
    await CartCoordinator.instance.addItem(
      CartItemModel(
        productId: p.id,
        name: p.name,
        imageUrl: p.imageUrl,
        unitPrice: p.price,
        quantity: quantity.clamp(1, 999),
      ),
    );
  }

  Future<WishlistActionResult> toggleWishlist() async {
    if (_isWishlisted) {
      return WishlistCoordinator.instance.removeItem(product.id);
    }

    return WishlistCoordinator.instance.addItem(
      WishlistItemModel(
        productId: product.id,
        name: product.name,
        imageUrl: product.imageUrl,
        sku: null,
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
