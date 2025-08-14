class TopUpMemberRequest {
  final String username;
  final int memberId;
  final String payment;
  final int amount;

  TopUpMemberRequest({
    required this.username,
    required this.memberId,
    required this.payment,
    required this.amount,
  });

  factory TopUpMemberRequest.fromJson(Map<String, dynamic> j) =>
      TopUpMemberRequest(
        username: j['username'] ?? '',
        memberId: (j['member_id'] as num?)?.toInt() ?? 0,
        payment: j['payment'] ?? '',
        amount: (j['amount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'member_id': memberId,
      'payment': payment,
      'amount': amount,
    };
  }
}
