class ListReview {
  bool? success;
  double? averageRating;
  int? reviewCount;
  List<Data>? data;

  ListReview({this.success, this.averageRating, this.reviewCount, this.data});

  ListReview.fromJson(Map<String, dynamic> json) {
    success = _asBool(json['success']);
    averageRating = _asDouble(json['averageRating']);
    reviewCount = _asInt(json['reviewCount']);
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['averageRating'] = this.averageRating;
    data['reviewCount'] = this.reviewCount;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  static bool? _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}

class Data {
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

  Data(
      {this.id,
      this.productId,
      this.userId,
      this.rating,
      this.title,
      this.comment,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.userName});

  Data.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    productId = _asInt(json['product_id']);
    userId = _asInt(json['user_id']);
    rating = _asInt(json['rating']);
    title = json['title']?.toString();
    comment = json['comment']?.toString();
    status = json['status']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    userName = json['user_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['user_id'] = this.userId;
    data['rating'] = this.rating;
    data['title'] = this.title;
    data['comment'] = this.comment;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_name'] = this.userName;
    return data;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }
}
