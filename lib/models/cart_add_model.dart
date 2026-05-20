class Cartadd {
  bool? success;
  String? message;
  CartAddData? data;

  Cartadd({this.success, this.message, this.data});

  Cartadd.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? CartAddData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class CartAddData {
  int? cartId;
  String? cartItemId;
  int? productId;
  int? quantity;

  CartAddData({this.cartId, this.cartItemId, this.productId, this.quantity});

  CartAddData.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    cartItemId = json['cart_item_id']?.toString();
    productId = json['product_id'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    data['cart_item_id'] = cartItemId;
    data['product_id'] = productId;
    data['quantity'] = quantity;
    return data;
  }
}
