class CreateMemberResponse {
  final String message;
  final int orderID;
  final String password;
  String qris;
  final bool success;
  final String username;

  CreateMemberResponse({
    required this.message,
    required this.orderID,
    required this.password,
    required this.qris,
    required this.success,
    required this.username,
  });

  factory CreateMemberResponse.fromJson(Map<String, dynamic> j) =>
      CreateMemberResponse(
        message: j['message'] ?? '',
        orderID: (j['orderID'] as num?)?.toInt() ?? 0,
        password: j['password'] ?? '',
        qris: j['qris'] ?? '',
        success: j['success'] ?? false,
        username: j['username'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'orderID': orderID,
      'password': password,
      'qris': qris,
      'success': success,
      'username': username,
    };
  }
}
