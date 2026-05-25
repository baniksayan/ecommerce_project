class AddReview {
  bool? success;
  String? message;

  AddReview({this.success, this.message});

  AddReview.fromJson(Map<String, dynamic> json) {
    success = json['success'] == true;
    message = (json['message'] ?? '').toString().trim();
    if (message!.isEmpty) {
      message = null;
    }
  }

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{};
    result['success'] = success;
    result['message'] = message;
    return result;
  }
}
