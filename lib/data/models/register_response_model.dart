class RegisterResponseModel {
  RegisterResponseModel({
    this.success,
    this.message,
  });

  final bool? success;
  final String? message;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
    };
  }
}