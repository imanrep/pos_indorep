class CreateOrderKulkasResponse {
  final String message;
  final bool success;
  final String qris;
  final int total;
  final String time;
  final int orderId;

  CreateOrderKulkasResponse({
    required this.message,
    required this.success,
    required this.qris,
    required this.total,
    required this.time,
    required this.orderId,
  });

  factory CreateOrderKulkasResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderKulkasResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
      qris: json['qris'] ?? '',
      total: json['total'] ?? 0,
      time: json['time'] ?? '',
      orderId: json['orderID'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
      'qris': qris,
      'total': total,
      'time': time,
      'orderID': orderId,
    };
  }
}
