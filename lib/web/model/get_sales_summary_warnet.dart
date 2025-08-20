class GetSalesSummaryWarnet {
  final List<Order> orders;
  final List<Package> packages;
  final Summary summary;

  GetSalesSummaryWarnet({
    required this.orders,
    required this.packages,
    required this.summary,
  });

  factory GetSalesSummaryWarnet.fromJson(Map<String, dynamic> json) {
    return GetSalesSummaryWarnet(
      orders: (json['orders'] as List<dynamic>)
          .map((e) => Order.fromJson(e))
          .toList(),
      packages: (json['packages'] as List<dynamic>)
          .map((e) => Package.fromJson(e))
          .toList(),
      summary: Summary.fromJson(json['summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((e) => e.toJson()).toList(),
      'packages': packages.map((e) => e.toJson()).toList(),
      'summary': summary.toJson(),
    };
  }
}

class Order {
  final int id;
  final String date;
  final String username;
  final String payment;
  final String note;
  final int amount;

  Order({
    required this.id,
    required this.date,
    required this.username,
    required this.payment,
    required this.note,
    required this.amount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      date: json['date'],
      username: json['username'],
      payment: json['payment'],
      note: json['note'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'username': username,
      'payment': payment,
      'note': note,
      'amount': amount,
    };
  }
}

class Package {
  final String packageName;
  final int qtySold;
  final int totalIncome;

  Package({
    required this.packageName,
    required this.qtySold,
    required this.totalIncome,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      packageName: json['package_name'],
      qtySold: json['qty_sold'],
      totalIncome: json['total_income'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'qty_sold': qtySold,
      'total_income': totalIncome,
    };
  }
}

class Summary {
  final String period;
  final String from;
  final String until;
  final int totalIncome;
  final int totalItems;
  final int totalOrders;

  Summary({
    required this.period,
    required this.from,
    required this.until,
    required this.totalIncome,
    required this.totalItems,
    required this.totalOrders,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      period: json['period'],
      from: json['from'],
      until: json['until'],
      totalIncome: json['total_income'],
      totalItems: json['total_items'],
      totalOrders: json['total_orders'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'from': from,
      'until': until,
      'total_income': totalIncome,
      'total_items': totalItems,
      'total_orders': totalOrders,
    };
  }
}
