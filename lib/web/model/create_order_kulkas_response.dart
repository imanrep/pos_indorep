class CreateOrderKulkasResponse {
  final bool success;
  final String message;
  final String qris; // empty for cash
  final num total;
  final String time;
  final int orderID;

  CreateOrderKulkasResponse({
    required this.success,
    required this.message,
    required this.qris,
    required this.total,
    required this.time,
    required this.orderID,
  });

  factory CreateOrderKulkasResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderKulkasResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      qris: (json['qris'] ?? '').toString(),
      total: (json['total'] is num)
          ? json['total']
          : num.tryParse('${json['total']}') ?? 0,
      time: (json['time'] ?? '').toString(),
      orderID: (json['orderID'] is int)
          ? json['orderID']
          : int.tryParse('${json['orderID']}') ?? 0,
    );
  }
}
