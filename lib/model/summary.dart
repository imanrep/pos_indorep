class ProductSummary {
  final String productName;
  final int qtySold;
  final int totalIncome;

  ProductSummary({
    required this.productName,
    required this.qtySold,
    required this.totalIncome,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      productName: json['product_name'] as String,
      qtySold: json['qty_sold'] as int,
      totalIncome: (json['total_income'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
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
      period: json['period'] as String,
      from: json['from'] as String,
      until: json['until'] as String,
      totalIncome: (json['total_income'] as num).toInt(),
      totalItems: (json['total_items'] as num).toInt(),
      totalOrders: (json['total_orders'] as num).toInt(),
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

class OrderSummary {
  final List<OrderProduct> products;
  final int totalIncome;
  final int off;
  final int actualAmount;

  OrderSummary({
    required this.products,
    required this.totalIncome,
    required this.off,
    required this.actualAmount,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List?;

    return OrderSummary(
      products: productList != null
          ? productList.map((item) => OrderProduct.fromJson(item)).toList()
          : [],
      totalIncome: json['total_income'] ?? 0,
      off: json['off'] ?? 0,
      actualAmount: json['actual_amount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products.map((e) => e.toJson()).toList(),
      'total_income': totalIncome,
      'off': off,
      'actual_amount': actualAmount,
    };
  }
}

class OrderProduct {
  final String productName;
  final int qtySold;
  final int amount;

  OrderProduct({
    required this.productName,
    required this.qtySold,
    required this.amount,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productName: json['product_name'],
      qtySold: json['qty_sold'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'qty_sold': qtySold,
      'amount': amount,
    };
  }
}

class SummaryResponse {
  final List<ProductSummary>? products;
  final List<OrderSummary>? orders;
  final Summary summary;

  SummaryResponse({
    this.products,
    this.orders,
    required this.summary,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List?;
    var orderList = json['orders'] as List?;

    return SummaryResponse(
      products:
          productList?.map((item) => ProductSummary.fromJson(item)).toList(),
      orders: orderList?.map((item) => OrderSummary.fromJson(item)).toList(),
      summary: Summary.fromJson(json['summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products?.map((e) => e.toJson()).toList() ?? [],
      'orders': orders?.map((e) => e.toJson()).toList() ?? [],
      'summary': summary.toJson(),
    };
  }
}
