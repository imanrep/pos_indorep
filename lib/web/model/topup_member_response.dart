class TopUpMemberResponse {
  final String message;
  final int orderID;
  String? qris;
  bool success;
  final int total;

  TopUpMemberResponse({
    required this.message,
    required this.orderID,
    this.qris,
    required this.success,
    required this.total,
  });

  factory TopUpMemberResponse.fromJson(Map<String, dynamic> j) =>
      TopUpMemberResponse(
        message: j['message'] ?? '',
        orderID: (j['order_id'] as num?)?.toInt() ?? 0,
        qris: j['qris'],
        success: j['success'] ?? false,
        total: (j['total'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'order_id': orderID,
      'qris': qris,
      'success': success,
      'total': total,
    };
  }
}
