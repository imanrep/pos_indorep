class ResetDisplayResponse {
  final bool success;

  ResetDisplayResponse({required this.success});

  factory ResetDisplayResponse.fromJson(Map<String, dynamic> json) {
    return ResetDisplayResponse(success: json['success'] == true);
  }
}
