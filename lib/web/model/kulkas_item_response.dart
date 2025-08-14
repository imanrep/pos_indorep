class GetKulkasItemResponse {
  final List<KulkasItem> message;
  final bool success;

  GetKulkasItemResponse({
    required this.message,
    required this.success,
  });

  factory GetKulkasItemResponse.fromJson(Map<String, dynamic> json) {
    return GetKulkasItemResponse(
      message: (json['message'] as List<dynamic>)
          .map((e) => KulkasItem.fromJson(e))
          .toList(),
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message.map((e) => e.toJson()).toList(),
      'success': success,
    };
  }
}

class KulkasItem {
  final int id;
  final String name;
  final int price;
  final bool onStock;

  KulkasItem({
    required this.id,
    required this.name,
    required this.price,
    required this.onStock,
  });

  factory KulkasItem.fromJson(Map<String, dynamic> json) {
    return KulkasItem(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      onStock: json['on_stock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'on_stock': onStock,
    };
  }
}
