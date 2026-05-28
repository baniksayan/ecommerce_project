class AgeVerificationList {
  bool? success;
  List<AgeVerificationData>? data;

  AgeVerificationList({this.success, this.data});

  AgeVerificationList.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <AgeVerificationData>[];
      json['data'].forEach((v) {
        data!.add(AgeVerificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AgeVerificationData {
  String? id;
  String? number;
  String? title;
  String? content;
  String? icon;

  AgeVerificationData({
    this.id,
    this.number,
    this.title,
    this.content,
    this.icon,
  });

  AgeVerificationData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    number = json['number'];
    title = json['title'];
    content = json['content'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['number'] = number;
    data['title'] = title;
    data['content'] = content;
    data['icon'] = icon;
    return data;
  }
}
