import 'auth_user_model.dart';

class VerifyLoginOtpResponseModel {
  VerifyLoginOtpResponseModel({
    this.success,
    this.message,
    this.token,
    this.user,
  });

  final bool? success;
  final String? message;
  final String? token;
  final AuthUserModel? user;

  factory VerifyLoginOtpResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = _readUserJson(json);
    return VerifyLoginOtpResponseModel(
      success: _parseBool(json['success']),
      message: json['message']?.toString(),
      token: _readToken(json),
      user: userJson == null ? null : AuthUserModel.fromJson(userJson),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'token': token,
      'user': user?.toJson(),
    };
  }

  static String? _readToken(Map<String, dynamic> json) {
    final rootToken = json['token'] ?? json['access_token'];
    if (rootToken != null && rootToken.toString().trim().isNotEmpty) {
      return rootToken.toString();
    }

    final data = json['data'];
    if (data is Map<String, dynamic>) {
      final dataToken = data['token'] ?? data['access_token'];
      if (dataToken != null && dataToken.toString().trim().isNotEmpty) {
        return dataToken.toString();
      }
    }

    return null;
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
