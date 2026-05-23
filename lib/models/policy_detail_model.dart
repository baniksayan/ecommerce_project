class PolicyDetail {
  bool? success;
  PolicyDetailData? data;

  PolicyDetail({this.success, this.data});

  PolicyDetail.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = PolicyDetailData.fromJson(rawData);
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class PolicyDetailData {
  int? id;
  String? title;
  String? slug;
  String? type;
  String? shortDescription;
  String? content;
  String? status;
  String? visibility;
  int? isFeatured;
  int? displayOrder;
  String? metaTitle;
  String? metaKeywords;
  String? metaDescription;
  String? createdAt;
  String? updatedAt;

  PolicyDetailData({
    this.id,
    this.title,
    this.slug,
    this.type,
    this.shortDescription,
    this.content,
    this.status,
    this.visibility,
    this.isFeatured,
    this.displayOrder,
    this.metaTitle,
    this.metaKeywords,
    this.metaDescription,
    this.createdAt,
    this.updatedAt,
  });

  PolicyDetailData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    title = json['title']?.toString();
    slug = json['slug']?.toString();
    type = json['type']?.toString();
    shortDescription = json['short_description']?.toString();
    content = json['content']?.toString();
    status = json['status']?.toString();
    visibility = json['visibility']?.toString();
    isFeatured = _asInt(json['is_featured']);
    displayOrder = _asInt(json['display_order']);
    metaTitle = json['meta_title']?.toString();
    metaKeywords = json['meta_keywords']?.toString();
    metaDescription = json['meta_description']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['slug'] = slug;
    map['type'] = type;
    map['short_description'] = shortDescription;
    map['content'] = content;
    map['status'] = status;
    map['visibility'] = visibility;
    map['is_featured'] = isFeatured;
    map['display_order'] = displayOrder;
    map['meta_title'] = metaTitle;
    map['meta_keywords'] = metaKeywords;
    map['meta_description'] = metaDescription;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
