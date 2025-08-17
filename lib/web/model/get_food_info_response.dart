class GetFoodInfoResponse {
  final String pc;
  final int total;
  final List<FoodItem> items;
  final DateTime time;

  GetFoodInfoResponse({
    required this.pc,
    required this.total,
    required this.items,
    required this.time,
  });

  factory GetFoodInfoResponse.fromJson(Map<String, dynamic> json) {
    return GetFoodInfoResponse(
      pc: json['pc'],
      total: json['total'],
      items: (json['items'] as List<dynamic>)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      time: DateTime.parse(json['time']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pc': pc,
      'total': total,
      'items': items.map((e) => e.toJson()).toList(),
      'time': time.toIso8601String(),
    };
  }
}

class FoodItem {
  final String name;
  final int qty;
  final int subTotal;
  final String note;
  final dynamic option;

  FoodItem({
    required this.name,
    required this.qty,
    required this.subTotal,
    required this.note,
    this.option,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      qty: json['qty'],
      subTotal: json['sub_total'],
      note: json['note'],
      option: json['option'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'qty': qty,
      'sub_total': subTotal,
      'note': note,
      'option': option,
    };
  }
}
