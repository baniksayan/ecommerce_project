class Wishlistlist {
  bool? success;
  WishlistData? data;

  Wishlistlist({this.success, this.data});

  Wishlistlist.fromJson(Map<String, dynamic> json) {
    success = _asBool(json['success']);
    data = json['data'] != null ? WishlistData.fromJson(json['data']) : null;
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

class WishlistData {
  int? userId;
  List<WishlistItem>? items;
  int? totalItems;

  WishlistData({this.userId, this.items, this.totalItems});

  WishlistData.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    if (json['items'] != null) {
      items = <WishlistItem>[];
      json['items'].forEach((v) {
        items!.add(WishlistItem.fromJson(v));
      });
    } else {
      items = <WishlistItem>[];
    }
    totalItems = json['total_items'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['total_items'] = totalItems;
    return data;
  }
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

class WishlistItem {
  int? id;
  int? productId;
  String? createdAt;
  String? name;
  String? price;
  String? images;
  String? sku;

  WishlistItem({
    this.id,
    this.productId,
    this.createdAt,
    this.name,
    this.price,
    this.images,
    this.sku,
  });

  WishlistItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    createdAt = json['created_at'];
    name = json['name'];
    price = json['price'];
    images = json['images'];
    sku = json['sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['created_at'] = createdAt;
    data['name'] = name;
    data['price'] = price;
    data['images'] = images;
    data['sku'] = sku;
    return data;
  }
}
