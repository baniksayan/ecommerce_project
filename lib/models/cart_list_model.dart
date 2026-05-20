class Cartlist {
  bool? success;
  CartListData? data;

  Cartlist({this.success, this.data});

  Cartlist.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? CartListData.fromJson(json['data']) : null;
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

class CartListData {
  int? cartId;
  int? userId;
  List<CartListItem>? items;
  int? totalItems;
  int? subtotal;

  CartListData({
    this.cartId,
    this.userId,
    this.items,
    this.totalItems,
    this.subtotal,
  });

  CartListData.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    userId = json['user_id'];
    if (json['items'] != null) {
      items = <CartListItem>[];
      json['items'].forEach((v) {
        items!.add(CartListItem.fromJson(v));
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

class CartListItem {
  CartListItem();

  CartListItem.fromJson(Map<String, dynamic> json);

  Map<String, dynamic> toJson() => <String, dynamic>{};
}
