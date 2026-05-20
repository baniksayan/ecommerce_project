import '../data/models/product_model.dart';
import '../models/product_list_model.dart';
import '../services/api_service.dart';
import 'base_viewmodel.dart';

enum ProductSort {
  popular,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  nameAZ,
}

enum ProductQuickFilter {
  all,
  bestSellers,
  under99,
  topRated,
  fastDelivery,
  discounted,
}

extension ProductQuickFilterX on ProductQuickFilter {
  String get label {
    switch (this) {
      case ProductQuickFilter.all:
        return 'All';
      case ProductQuickFilter.bestSellers:
        return 'Best Sellers';
      case ProductQuickFilter.under99:
        return 'Under ₹99';
      case ProductQuickFilter.topRated:
        return 'Top Rated';
      case ProductQuickFilter.fastDelivery:
        return 'Fast Delivery';
      case ProductQuickFilter.discounted:
        return 'Discounted';
    }
  }
}

extension ProductSortX on ProductSort {
  String get label {
    switch (this) {
      case ProductSort.popular:
        return 'Popular';
      case ProductSort.priceLowToHigh:
        return 'Price: Low to High';
      case ProductSort.priceHighToLow:
        return 'Price: High to Low';
      case ProductSort.ratingHighToLow:
        return 'Rating';
      case ProductSort.nameAZ:
        return 'Name: A–Z';
    }
  }

  ProductSort get next {
    final values = ProductSort.values;
    return values[(index + 1) % values.length];
  }
}

class ProductListingViewModel extends BaseViewModel {
  final ProductCategory category;
  final ApiService _apiService = ApiService();

  ProductListingViewModel({required this.category});

  List<ProductModel> _products = const <ProductModel>[];
  List<ProductModel> get products => _products;

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  ProductSort _sort = ProductSort.popular;
  ProductSort get sort => _sort;

  ProductQuickFilter _quickFilter = ProductQuickFilter.all;
  ProductQuickFilter get quickFilter => _quickFilter;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = false;
  bool get hasMore => _hasMore;

  List<ProductModel> get filteredProducts {
    final q = _searchQuery.trim().toLowerCase();
    final List<ProductModel> base = q.isEmpty
        ? [..._products]
        : _products.where((p) => p.name.toLowerCase().contains(q)).toList();

    final List<ProductModel> filtered = switch (_quickFilter) {
      ProductQuickFilter.all => base,
      ProductQuickFilter.bestSellers =>
        base.where((p) => p.isBestSeller == true).toList(),
      ProductQuickFilter.under99 => base.where((p) => p.price < 99).toList(),
      ProductQuickFilter.topRated =>
        base.where((p) => (p.rating ?? 0.0) >= 4.5).toList(),
      ProductQuickFilter.fastDelivery =>
        base.where((p) => p.isFastDelivery == true).toList(),
      ProductQuickFilter.discounted =>
        base.where((p) => p.hasDiscount).toList(),
    };

    switch (_sort) {
      case ProductSort.popular:
        return filtered;
      case ProductSort.priceLowToHigh:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        return filtered;
      case ProductSort.priceHighToLow:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        return filtered;
      case ProductSort.ratingHighToLow:
        filtered.sort((a, b) {
          final ar = a.rating ?? 0.0;
          final br = b.rating ?? 0.0;
          final primary = br.compareTo(ar);
          if (primary != 0) return primary;
          return b.price.compareTo(a.price);
        });
        return filtered;
      case ProductSort.nameAZ:
        filtered.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        return filtered;
    }
  }

  Future<void> load() async {
    setLoading(true);
    clearError();
    try {
      final response = await _apiService.getProducts();
      final mapped = (response.data ?? const <ProductItemModel>[])
          .asMap()
          .entries
          .map((entry) => _mapApiProduct(entry.value, entry.key))
          .where((p) => p.category == category)
          .toList(growable: false);

      _products = mapped;

      _hasMore = false;
    } catch (_) {
      setError('Failed to load products.');
    } finally {
      setLoading(false);
    }
  }

  ProductModel _mapApiProduct(ProductItemModel item, int index) {
    final id = item.id?.toString() ?? 'listing-api-$index';
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

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    notifyListeners();
  }

  void setSort(ProductSort sort) {
    if (_sort == sort) return;
    _sort = sort;
    notifyListeners();
  }

  void setQuickFilter(ProductQuickFilter filter) {
    if (_quickFilter == filter) return;
    _quickFilter = filter;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore) return;
    if (!_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _hasMore = false;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}
