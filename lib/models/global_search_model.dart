class GlobalSearch {
  bool? success;
  String? message;
  String? query;
  String? normalizedQuery;
  String? didYouMean;
  GlobalSearchData? data;
  GlobalSearchMeta? meta;

  GlobalSearch({
    this.success,
    this.message,
    this.query,
    this.normalizedQuery,
    this.didYouMean,
    this.data,
    this.meta,
  });

  GlobalSearch.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    message = _asString(json['message']);
    query = _asString(json['query']);
    normalizedQuery = _asString(json['normalized_query']);
    didYouMean = _asString(json['did_you_mean']);

    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = GlobalSearchData.fromJson(rawData);
    }

    final rawMeta = json['meta'];
    if (rawMeta is Map<String, dynamic>) {
      meta = GlobalSearchMeta.fromJson(rawMeta);
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    map['query'] = query;
    map['normalized_query'] = normalizedQuery;
    map['did_you_mean'] = didYouMean;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    if (meta != null) {
      map['meta'] = meta!.toJson();
    }
    return map;
  }
}

class GlobalSearchData {
  List<GlobalSearchItem>? products;
  List<GlobalSearchCategory>? categories;
  List<String>? suggestions;
  List<GlobalSearchItem>? related;

  GlobalSearchData({
    this.products,
    this.categories,
    this.suggestions,
    this.related,
  });

  GlobalSearchData.fromJson(Map<String, dynamic> json) {
    products = _asListMap(
      json['products'],
    ).map((v) => GlobalSearchItem.fromJson(v)).toList(growable: false);

    categories = _asListMap(
      json['categories'],
    ).map((v) => GlobalSearchCategory.fromJson(v)).toList(growable: false);

    final rawSuggestions = json['suggestions'];
    if (rawSuggestions is List) {
      suggestions = rawSuggestions
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    } else {
      suggestions = const <String>[];
    }

    related = _asListMap(
      json['related'],
    ).map((v) => GlobalSearchItem.fromJson(v)).toList(growable: false);
  }

  List<GlobalSearchItem> get mergedProductResults {
    final byId = <String, GlobalSearchItem>{};

    for (final item in products ?? const <GlobalSearchItem>[]) {
      final key = (item.id?.toString() ?? item.slug ?? item.name ?? '').trim();
      if (key.isEmpty) continue;
      byId[key] = item;
    }

    for (final item in related ?? const <GlobalSearchItem>[]) {
      final key = (item.id?.toString() ?? item.slug ?? item.name ?? '').trim();
      if (key.isEmpty) continue;
      byId[key] = byId[key] ?? item;
    }

    return byId.values.toList(growable: false);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['products'] = (products ?? const <GlobalSearchItem>[])
        .map((v) => v.toJson())
        .toList();
    map['categories'] = (categories ?? const <GlobalSearchCategory>[])
        .map((v) => v.toJson())
        .toList();
    map['suggestions'] = suggestions ?? const <String>[];
    map['related'] = (related ?? const <GlobalSearchItem>[])
        .map((v) => v.toJson())
        .toList();
    return map;
  }
}

class GlobalSearchItem {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? shortDescription;
  String? price;
  String? discountPrice;
  int? discountPercentage;
  String? sku;
  int? stockQuantity;
  int? categoryId;
  String? images;
  String? weight;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? stock;
  String? attributes;
  String? categoryName;
  bool? isInStock;
  bool? freeDelivery;
  String? deliveryType;

  GlobalSearchItem({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.shortDescription,
    this.price,
    this.discountPrice,
    this.discountPercentage,
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
    this.isInStock,
    this.freeDelivery,
    this.deliveryType,
  });

  GlobalSearchItem.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = _asString(json['name']);
    slug = _asString(json['slug']);
    description = _asString(json['description']);
    shortDescription = _asString(
      json['short_description'] ?? json['shortDescription'],
    );
    price = _asString(json['price']);
    discountPrice = _asString(json['discount_price']);
    discountPercentage = _asInt(
      json['discount_percentage'] ?? json['discountPercentage'],
    );
    sku = _asString(json['sku']);
    stockQuantity = _asInt(json['stock_quantity']);
    categoryId = _asInt(json['category_id']);
    images = _asImageString(json['images']);
    weight = _asString(json['weight']);
    isActive = _asInt(json['is_active']);
    createdAt = _asString(json['created_at']);
    updatedAt = _asString(json['updated_at']);
    stock = _asInt(json['stock']);
    attributes = _asString(json['attributes']);
    categoryName = _asString(json['category_name']);
    isInStock = _asBool(json['is_in_stock'] ?? json['isInStock']);
    freeDelivery = _asBool(json['free_delivery'] ?? json['freeDelivery']);
    deliveryType = _asString(json['delivery_type'] ?? json['deliveryType']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    map['description'] = description;
    map['short_description'] = shortDescription;
    map['price'] = price;
    map['discount_price'] = discountPrice;
    map['discount_percentage'] = discountPercentage;
    map['sku'] = sku;
    map['stock_quantity'] = stockQuantity;
    map['category_id'] = categoryId;
    map['images'] = images;
    map['weight'] = weight;
    map['is_active'] = isActive;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['stock'] = stock;
    map['attributes'] = attributes;
    map['category_name'] = categoryName;
    map['is_in_stock'] = isInStock;
    map['free_delivery'] = freeDelivery;
    map['delivery_type'] = deliveryType;
    return map;
  }
}

class GlobalSearchCategory {
  int? id;
  String? name;
  String? slug;

  GlobalSearchCategory({this.id, this.name, this.slug});

  GlobalSearchCategory.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = _asString(json['name']);
    slug = _asString(json['slug']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    return map;
  }
}

class GlobalSearchMeta {
  int? totalProducts;
  int? totalCategories;
  double? searchTimeMs;
  int? page;
  int? limit;

  GlobalSearchMeta({
    this.totalProducts,
    this.totalCategories,
    this.searchTimeMs,
    this.page,
    this.limit,
  });

  GlobalSearchMeta.fromJson(Map<String, dynamic> json) {
    totalProducts = _asInt(json['total_products']);
    totalCategories = _asInt(json['total_categories']);
    searchTimeMs = _asDouble(json['search_time_ms']);
    page = _asInt(json['page']);
    limit = _asInt(json['limit']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['total_products'] = totalProducts;
    map['total_categories'] = totalCategories;
    map['search_time_ms'] = searchTimeMs;
    map['page'] = page;
    map['limit'] = limit;
    return map;
  }
}

List<Map<String, dynamic>> _asListMap(Object? raw) {
  if (raw is! List) return const <Map<String, dynamic>>[];
  return raw.whereType<Map<String, dynamic>>().toList(growable: false);
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

double? _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _asString(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

bool? _asBool(Object? value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  final text = value?.toString().trim().toLowerCase() ?? '';
  if (text.isEmpty || text == 'null') return null;
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

String? _asImageString(Object? value) {
  if (value is List) {
    for (final entry in value) {
      final text = _asString(entry);
      if (text != null) return text;
    }
    return null;
  }

  return _asString(value);
}
