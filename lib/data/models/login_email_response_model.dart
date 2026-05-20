class LoginEmailResponseModel {
  LoginEmailResponseModel({
    this.success,
    this.message,
  });

  final bool? success;
  final String? message;

  factory LoginEmailResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginEmailResponseModel(
      success: _parseBool(json['success']),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
    };
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value.toString().trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
    return null;
  }
}