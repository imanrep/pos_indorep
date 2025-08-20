class KulkasOrderItem {
  final int id;
  final int qty;
  KulkasOrderItem({required this.id, required this.qty});
  Map<String, dynamic> toJson() => {'id': id, 'qty': qty};
}

class CreateOrderKulkasRequest {
  final String payment; // "cash" | "qris"
  final List<KulkasOrderItem> orders;
  CreateOrderKulkasRequest({required this.payment, required this.orders});
  Map<String, dynamic> toJson() => {
        'payment': payment,
        'orders': orders.map((e) => e.toJson()).toList(),
      };
}
