class AuthUserModel {
  AuthUserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.token,
    this.raw,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? token;
  final Map<String, dynamic>? raw;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] ?? json['user_id'])?.toString(),
      name: (json['name'] ?? json['full_name'])?.toString(),
      email: json['email']?.toString(),
      phone: (json['phone'] ?? json['mobile'])?.toString(),
      token: (json['token'] ?? json['access_token'])?.toString(),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'raw': raw,
    };
  }
}