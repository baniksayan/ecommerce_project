class UpdateCoupon {
  bool? success;
  String? message;

  UpdateCoupon({this.success, this.message});

  UpdateCoupon.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    final msg = (json['message'] ?? '').toString().trim();
    message = msg.isEmpty ? null : msg;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    return map;
  }
}
