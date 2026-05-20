class Cartdetail {
  bool? success;
  CartDetailData? data;

  Cartdetail({this.success, this.data});

  Cartdetail.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? CartDetailData.fromJson(json['data']) : null;
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

class CartDetailData {
  int? cartId;
  int? userId;
  List<CartDetailItem>? items;
  int? totalItems;
  int? subtotal;

  CartDetailData({
    this.cartId,
    this.userId,
    this.items,
    this.totalItems,
    this.subtotal,
  });

  CartDetailData.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    userId = json['user_id'];
    if (json['items'] != null) {
      items = <CartDetailItem>[];
      json['items'].forEach((v) {
        items!.add(CartDetailItem.fromJson(v));
      });
    }
    totalItems = json['total_items'];
    subtotal = json['subtotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['user_id'] = userId;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['total_items'] = totalItems;
    data['subtotal'] = subtotal;
    return data;
  }
}

class CartDetailItem {
  int? id;
  int? productId;
  int? quantity;
  String? priceAtPurchase;
  String? name;
  String? price;
  String? images;
  String? sku;

  CartDetailItem({
    this.id,
    this.productId,
    this.quantity,
    this.priceAtPurchase,
    this.name,
    this.price,
    this.images,
    this.sku,
  });

  CartDetailItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    quantity = json['quantity'];
    priceAtPurchase = json['price_at_purchase'];
    name = json['name'];
    price = json['price'];
    images = json['images'];
    sku = json['sku'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    data['price_at_purchase'] = priceAtPurchase;
    data['name'] = name;
    data['price'] = price;
    data['images'] = images;
    data['sku'] = sku;
    return data;
  }
}
