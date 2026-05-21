class Productlist {
  bool? success;
  List<ProductItemModel>? data;

  Productlist({this.success, this.data});

  Productlist.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <ProductItemModel>[];
      json['data'].forEach((v) {
        data!.add(ProductItemModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductItemModel {
  int? id;
  String? name;
  String? price;
  String? images;
  String? categoryName;

  ProductItemModel({
    this.id,
    this.name,
    this.price,
    this.images,
    this.categoryName,
  });

  ProductItemModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['product_id'] ?? json['productId'];
    id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    name = json['name'];
    price = json['price'];
    images = json['images'];
    categoryName = json['category_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['images'] = images;
    data['category_name'] = categoryName;
    return data;
  }
}
