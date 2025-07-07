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

class SummaryResponse {
  final List<ProductSummary>? products;
  final Summary summary;

  SummaryResponse({
    this.products,
    required this.summary,
  });

  factory SummaryResponse.fromJson(Map<String, dynamic> json) {
    var productList = json['products'] as List?;
    List<ProductSummary>? products = productList
        ?.map((item) => ProductSummary.fromJson(item as Map<String, dynamic>))
        .toList();

    return SummaryResponse(
      products: products,
      summary: Summary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'products': products?.map((e) => e.toJson()).toList() ?? [],
      'summary': summary.toJson(),
    };
  }
}
