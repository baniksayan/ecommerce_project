class Profile {
  bool? success;
  ProfileData? data;

  Profile({this.success, this.data});

  Profile.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    final rawData = json['data'];
    if (rawData is Map<String, dynamic>) {
      data = ProfileData.fromJson(rawData);
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['success'] = success;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class ProfileData {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? role;
  String? address;
  String? city;
  String? state;
  String? country;
  String? profileImage;
  String? pincode;
  String? createdAt;

  ProfileData({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.role,
    this.address,
    this.city,
    this.state,
    this.country,
    this.profileImage,
    this.pincode,
    this.createdAt,
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = _asString(json['name']);
    email = _asString(json['email']);
    phone = _asString(json['phone']);
    role = _asString(json['role']);
    address = _asString(json['address']);
    city = _asString(json['city']);
    state = _asString(json['state']);
    country = _asString(json['country']);
    profileImage = _asString(json['profile_image']);
    pincode = _asString(json['pincode']);
    createdAt = _asString(json['created_at']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['email'] = email;
    map['phone'] = phone;
    map['role'] = role;
    map['address'] = address;
    map['city'] = city;
    map['state'] = state;
    map['country'] = country;
    map['profile_image'] = profileImage;
    map['pincode'] = pincode;
    map['created_at'] = createdAt;
    return map;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static String? _asString(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') {
      return null;
    }
    return text;
  }
}
