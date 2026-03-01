import 'package:flutter/foundation.dart';

enum ProductCategory { grocery, beauty, shoes, fresh, snacks, drinks, dairy }

extension ProductCategoryX on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.grocery:
        return 'Grocery';
      case ProductCategory.beauty:
        return 'Beauty';
      case ProductCategory.shoes:
        return 'Shoes';
      case ProductCategory.fresh:
        return 'Fresh';
      case ProductCategory.snacks:
        return 'Snacks';
      case ProductCategory.drinks:
        return 'Drinks';
      case ProductCategory.dairy:
        return 'Dairy';
    }
  }

  String get searchHint {
    switch (this) {
      case ProductCategory.grocery:
        return 'groceries';
      case ProductCategory.beauty:
        return 'beauty';
      case ProductCategory.shoes:
        return 'shoes';
      case ProductCategory.fresh:
        return 'fresh items';
      case ProductCategory.snacks:
        return 'snacks';
      case ProductCategory.drinks:
        return 'drinks';
      case ProductCategory.dairy:
        return 'dairy';
    }
  }
}

@immutable
class ProductModel {
  final String id;
  final ProductCategory category;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String? discountTag;
  final double? rating;
  final int? reviewCount;

  const ProductModel({
    required this.id,
    required this.category,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountTag,
    this.rating,
    this.reviewCount,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price || discountTag != null;

  ProductModel copyWith({
    String? id,
    ProductCategory? category,
    String? name,
    String? imageUrl,
    double? price,
    double? originalPrice,
    String? discountTag,
    double? rating,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      discountTag: discountTag ?? this.discountTag,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
