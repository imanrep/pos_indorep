import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';

class TransactionDetailView extends StatefulWidget {
  final TransactionModel transaction;
  const TransactionDetailView({required this.transaction, super.key});

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Text('Detail Transaksi'),
          Text('Nama: ${widget.transaction.nama}'),
          Text(
              'Tanggal: ${Helper.dateFormatter(widget.transaction.transactionDate)}'),
          Text('Pesanan:'),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.transaction.cart.length,
            itemBuilder: (context, index) {
              final cart = widget.transaction.cart[index];
              return ListTile(
                title: Text(cart.title),
                subtitle:
                    Text('${cart.qty} x ${Helper.rupiahFormatter(cart.price)}'),
              );
            },
          ),
          Text('Total: ${Helper.rupiahFormatter(widget.transaction.total)}'),
          Text('Payment Method: ${widget.transaction.paymentMethod}'),
        ],
      ),
    );
  }
}
