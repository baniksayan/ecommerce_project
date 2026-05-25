class ListReview {
  bool? success;
  List<ReviewData>? data;

  ListReview({this.success, this.data});

  ListReview.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    final rawList = json['data'];
    if (rawList is List) {
      data = rawList
          .whereType<Map<String, dynamic>>()
          .map((v) => ReviewData.fromJson(v))
          .toList(growable: false);
    } else {
      data = const <ReviewData>[];
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['success'] = success;
    result['data'] = (data ?? const <ReviewData>[])
        .map((v) => v.toJson())
        .toList();
    return result;
  }
}

class ReviewData {
  int? id;
  int? productId;
  int? userId;
  int? rating;
  String? title;
  String? comment;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? userName;

  ReviewData({
    this.id,
    this.productId,
    this.userId,
    this.rating,
    this.title,
    this.comment,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
  });

  ReviewData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    productId = _asInt(json['product_id']);
    userId = _asInt(json['user_id']);
    rating = _asInt(json['rating']);
    title = _asString(json['title']);
    comment = _asString(json['comment']);
    status = _asString(json['status']);
    createdAt = _asString(json['created_at']);
    updatedAt = _asString(json['updated_at']);
    userName = _asString(json['user_name']);
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['id'] = id;
    result['product_id'] = productId;
    result['user_id'] = userId;
    result['rating'] = rating;
    result['title'] = title;
    result['comment'] = comment;
    result['status'] = status;
    result['created_at'] = createdAt;
    result['updated_at'] = updatedAt;
    result['user_name'] = userName;
    return result;
  }
}

int? _asInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _asString(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
