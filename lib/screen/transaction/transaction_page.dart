import 'package:flutter/material.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_detail_view.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_list_view.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<TransactionProvider>(context, listen: false)
        .getAllTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      return Scaffold(
          body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: SingleChildScrollView(
                  child: Column(children: [
                TransactionListView(
                    transactions: provider.transactions,
                    onTransactionTap: (transaction) {
                      provider.selectTransaction(transaction);
                    }),
              ]))),
          const VerticalDivider(thickness: 0.5, width: 1),
          Expanded(
              flex: 2,
              child: Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                if (provider.selectedTransaction == null) {
                  return Container();
                }
                return TransactionDetailView(
                    transaction: provider.selectedTransaction!);
              })),
        ],
      ));
    });
  }
}
