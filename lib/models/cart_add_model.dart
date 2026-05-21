class Cartadd {
  bool? success;
  String? message;
  Data? data;

  Cartadd({this.success, this.message, this.data});

  Cartadd.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  int? cartId;
  int? cartItemId;
  int? productId;
  int? quantity;

  Data({this.cartId, this.cartItemId, this.productId, this.quantity});

  Data.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    cartItemId = json['cart_item_id'];
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
