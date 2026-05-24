class Productdetails {
  bool? success;
  ProductDetailData? data;

  Productdetails({this.success, this.data});

  Productdetails.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null
        ? ProductDetailData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProductDetailData {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? price;
  String? discountPrice;
  String? sku;
  int? stockQuantity;
  int? categoryId;
  List<String>? images;
  String? weight;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? stock;
  String? attributes;
  String? categoryName;

  ProductDetailData({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.price,
    this.discountPrice,
    this.sku,
    this.stockQuantity,
    this.categoryId,
    this.images,
    this.weight,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.stock,
    this.attributes,
    this.categoryName,
  });

  ProductDetailData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id'] ?? json['product_id'] ?? json['productId']);
    name = _asString(json['name']);
    slug = _asString(json['slug']);
    description = _asString(json['description']);
    price = _asString(json['price']);
    discountPrice = _asString(json['discount_price']);
    sku = _asString(json['sku']);
    stockQuantity = _asInt(json['stock_quantity']);
    categoryId = _asInt(json['category_id']);

    final rawImages = json['images'];
    if (rawImages is List) {
      images = rawImages
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    } else if (rawImages is String && rawImages.trim().isNotEmpty) {
      images = rawImages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    } else {
      images = <String>[];
    }

    weight = _asString(json['weight']);
    isActive = _asInt(json['is_active']);
    createdAt = _asString(json['created_at']);
    updatedAt = _asString(json['updated_at']);
    stock = _asInt(json['stock']);
    attributes = _asString(json['attributes']);
    categoryName = _asString(json['category_name']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['price'] = price;
    data['discount_price'] = discountPrice;
    data['sku'] = sku;
    data['stock_quantity'] = stockQuantity;
    data['category_id'] = categoryId;
    data['images'] = images;
    data['weight'] = weight;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['stock'] = stock;
    data['attributes'] = attributes;
    data['category_name'] = categoryName;
    return data;
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _asString(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}
