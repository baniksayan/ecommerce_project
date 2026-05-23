class ManagePolicies {
  bool? success;
  String? message;

  ManagePolicies({this.success, this.message});

  ManagePolicies.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    message = json['message']?.toString();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    map['message'] = message;
    return map;
  }
}
