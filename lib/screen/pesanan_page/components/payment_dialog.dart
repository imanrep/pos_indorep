import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class PaymentDialog extends StatefulWidget {
  final TransactionModel transaction;

  const PaymentDialog({
    super.key,
    required this.transaction,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _paymentMethods = [
    'Cash',
    'QRIS',
    'Card',
  ];

  String? _selectedPaymentMethod;

  Future<void> _handlePayment() async {
    final TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    TransactionModel currentTransaction = TransactionModel(
        nama: _nameController.text,
        transactionId: widget.transaction.transactionId,
        transactionDate: widget.transaction.transactionDate,
        cart: widget.transaction.cart,
        total: widget.transaction.total,
        paymentMethod: _selectedPaymentMethod!);
    // transactionProvider.addTransaction(currentTransaction);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Konfirmasi Pesanan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Atas nama'),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Masukkan nama pelanggan';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Metode Pembayaran'),
            items: _paymentMethods.map((method) {
              return DropdownMenuItem<String>(
                value: method,
                child: Text(method),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            validator: (value) =>
                value == null ? 'Masukkan metode pembayaran' : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedPaymentMethod != null &&
                _nameController.text.isNotEmpty) {
              _handlePayment();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pesanan berhasil dibuat!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lengkapi detail pesanan!')),
              );
            }
          },
          child: Text('Bayar'),
        ),
      ],
    );
  }
}
