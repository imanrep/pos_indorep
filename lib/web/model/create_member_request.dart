class CreateMemberRequest {
  final String username;
  final String password;
  final String payment;
  final int amount;
  final bool isPaketMalam;

  CreateMemberRequest({
    required this.username,
    required this.password,
    required this.payment,
    required this.amount,
    required this.isPaketMalam,
  });

  factory CreateMemberRequest.fromJson(Map<String, dynamic> j) =>
      CreateMemberRequest(
        username: j['username'] ?? '',
        password: j['password'] ?? '',
        payment: j['payment'] ?? '',
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        isPaketMalam: j['is_paket_malam'] ?? false,
      );

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'payment': payment,
      'amount': amount,
      'is_paket_malam': isPaketMalam,
    };
  }
}
