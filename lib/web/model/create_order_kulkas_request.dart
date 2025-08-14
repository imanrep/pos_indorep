class CreateOrderKulkasRequest {
  final List<OrderKulkas> orders;
  final String payment;

  CreateOrderKulkasRequest({
    required this.orders,
    required this.payment,
  });

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'payment': payment,
    };
  }
}

class OrderKulkas {
  final int id;
  final int qty;

  OrderKulkas({
    required this.id,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qty': qty,
    };
  }
}
