import 'auth_user_model.dart';

class VerifyLoginOtpResponseModel {
  VerifyLoginOtpResponseModel({
    this.success,
    this.message,
    this.user,
  });

  final bool? success;
  final String? message;
  final AuthUserModel? user;

  factory VerifyLoginOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = _readUserJson(json);
    return VerifyLoginOtpResponseModel(
      success: _parseBool(json['success']),
      message: json['message']?.toString(),
      user: userJson == null ? null : AuthUserModel.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'user': user?.toJson(),
    };
  }

  static Map<String, dynamic>? _readUserJson(Map<String, dynamic> json) {
    final user = json['user'];
    if (user is Map<String, dynamic>) return user;

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final nestedUser = data['user'];
      if (nestedUser is Map<String, dynamic>) return nestedUser;
      return data;
    }

    return null;
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