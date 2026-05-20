class Categories {
  bool? success;
  List<CategoryItemModel>? data;

  Categories({this.success, this.data});

  Categories.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <CategoryItemModel>[];
      json['data'].forEach((v) {
        data!.add(CategoryItemModel.fromJson(v));
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

class CategoryItemModel {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? image;
  int? isActive;

  CategoryItemModel({
    this.id,
    this.name,
    this.slug,
    this.description,
    this.image,
    this.isActive,
  });

  CategoryItemModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    image = json['image'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['description'] = description;
    data['image'] = image;
    data['is_active'] = isActive;
    return data;
  }
}
