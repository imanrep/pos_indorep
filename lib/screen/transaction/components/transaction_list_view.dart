import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';

class TransactionListView extends StatelessWidget {
  final List<TransactionModel> transactions;
  final Function(String) onTransactionTap;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return ListTile(
          onTap: () => onTransactionTap(transaction.transactionId),
          title: Text(Helper.rupiahFormatter(transaction.total)),
          subtitle: Text(transaction.transactionDate.toString()),
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(transaction.cart.first.image)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
