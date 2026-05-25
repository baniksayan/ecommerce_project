class ListCoupons {
  bool? success;
  List<CouponData>? data;

  ListCoupons({this.success, this.data});

  ListCoupons.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    final raw = json['data'];
    if (raw is List) {
      data = raw
          .whereType<Map<String, dynamic>>()
          .map((v) => CouponData.fromJson(v))
          .toList(growable: false);
    } else {
      data = const <CouponData>[];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['data'] = (data ?? const <CouponData>[])
        .map((v) => v.toJson())
        .toList();
    return map;
  }
}

class CouponData {
  int? id;
  String? code;
  int? discount;
  String? expiry;

  CouponData({this.id, this.code, this.discount, this.expiry});

  CouponData.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    code = _toString(json['code']);
    discount = _toInt(json['discount']);
    expiry = _toString(json['expiry']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['code'] = code;
    map['discount'] = discount;
    map['expiry'] = expiry;
    return map;
  }
}

int? _toInt(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String? _toString(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
