class GetTransactionWarnetResponse {
  final List<WarnetTransaction> data;
  final int currentPage;
  final int totalPages;
  final int totalTransaction;

  GetTransactionWarnetResponse({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalTransaction,
  });

  factory GetTransactionWarnetResponse.fromJson(Map<String, dynamic> json) {
    return GetTransactionWarnetResponse(
      data: List<WarnetTransaction>.from(
        json['data'].map((item) => WarnetTransaction.fromJson(item)),
      ),
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalTransaction: json['total_transaction'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_transaction': totalTransaction,
    };
  }
}

class WarnetTransaction {
  final int id;
  final DateTime date;
  final String username;
  final String password;
  final String payment;
  final String note;
  final String status;
  final int amount;

  WarnetTransaction({
    required this.id,
    required this.date,
    required this.username,
    required this.password,
    required this.payment,
    required this.note,
    required this.status,
    required this.amount,
  });

  factory WarnetTransaction.fromJson(Map<String, dynamic> json) {
    return WarnetTransaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      username: json['username'],
      password: json['password'] == "NULL" ? "" : json['password'],
      payment: json['payment'],
      note: json['note'],
      status: json['status'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'username': username,
      'password': password.isEmpty ? "NULL" : password,
      'payment': payment,
      'note': note,
      'status': status,
      'amount': amount,
    };
  }
}
