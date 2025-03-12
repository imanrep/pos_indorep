import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class TransactionListView extends StatefulWidget {
  final List<TransactionModel> transactions;
  final Function(TransactionModel) onTransactionTap;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.transactions.length,
        itemBuilder: (context, index) {
          final transaction = widget.transactions[index];
          String total = Helper.rupiahFormatter(transaction.total);
          String date = Helper.dateFormatter(transaction.transactionDate);
          String time = Helper.timeFormatter(transaction.transactionDate);
          String totalCart = transaction.cart.length.toString();
          return Container(
            decoration: BoxDecoration(
              color: transaction.transactionId ==
                      provider.selectedTransaction?.transactionId
                  ? Colors.black12
                  : Colors.transparent,
            ),
            child: ListTile(
              onTap: () => widget.onTransactionTap(transaction),
              title: Text('${transaction.nama} | $date - $time'),
              subtitle: Text(
                  '$totalCart Menu, $total (${transaction.paymentMethod})'),
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Text(transaction.nama[0],
                    style: TextStyle(color: Colors.white)),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.grey,
              ),
            ),
          );
        },
      );
    });
  }
}
