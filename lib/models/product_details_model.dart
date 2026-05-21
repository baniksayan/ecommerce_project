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
  dynamic weight;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? stock;
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
    this.categoryName,
  });

  ProductDetailData.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['product_id'] ?? json['productId'];
    id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    price = json['price'];
    discountPrice = json['discount_price'];
    sku = json['sku'];
    stockQuantity = json['stock_quantity'];
    categoryId = json['category_id'];

    final rawImages = json['images'];
    if (rawImages is List) {
      images = rawImages.map((e) => e.toString()).toList();
    } else if (rawImages is String && rawImages.trim().isNotEmpty) {
      images = rawImages
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      images = <String>[];
    }

    weight = json['weight'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    stock = json['stock'];
    categoryName = json['category_name'];
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
    data['category_name'] = categoryName;
    return data;
  }
}
