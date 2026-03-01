import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';
import 'base_viewmodel.dart';

enum ProductSort {
  popular,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  nameAZ,
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
  final ProductRepository _repository;
  final ProductCategory category;

  ProductListingViewModel({
    required ProductRepository repository,
    required this.category,
  }) : _repository = repository;

  List<ProductModel> _products = const <ProductModel>[];
  List<ProductModel> get products => _products;

  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  ProductSort _sort = ProductSort.popular;
  ProductSort get sort => _sort;

  List<ProductModel> get filteredProducts {
    final q = _searchQuery.trim().toLowerCase();
    final List<ProductModel> base = q.isEmpty
        ? [..._products]
        : _products.where((p) => p.name.toLowerCase().contains(q)).toList();

    switch (_sort) {
      case ProductSort.popular:
        return base;
      case ProductSort.priceLowToHigh:
        base.sort((a, b) => a.price.compareTo(b.price));
        return base;
      case ProductSort.priceHighToLow:
        base.sort((a, b) => b.price.compareTo(a.price));
        return base;
      case ProductSort.ratingHighToLow:
        base.sort((a, b) {
          final ar = a.rating ?? 0.0;
          final br = b.rating ?? 0.0;
          final primary = br.compareTo(ar);
          if (primary != 0) return primary;
          return b.price.compareTo(a.price);
        });
        return base;
      case ProductSort.nameAZ:
        base.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        return base;
    }
  }

  Future<void> load() async {
    setLoading(true);
    clearError();
    try {
      _products = await _repository.getProducts(category);
    } catch (_) {
      setError('Failed to load products.');
    } finally {
      setLoading(false);
    }
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
}
