import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

class PaymentDialogBottomSheet extends StatefulWidget {
  final TransactionModel transaction;
  final QrisOrderResponse qrisOrderResponse;

  const PaymentDialogBottomSheet({
    super.key,
    required this.transaction,
    required this.qrisOrderResponse,
  });

  @override
  State<PaymentDialogBottomSheet> createState() =>
      _PaymentDialogBottomSheetState();
}

class _PaymentDialogBottomSheetState extends State<PaymentDialogBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _paymentMethods = [
    'Cash',
    'QRIS',
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Konfirmasi Pembayaran',
              style:
                  GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
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
          const SizedBox(height: 16),
          Container(
            height: 200,
            child: PrettyQrView.data(
              data: widget.qrisOrderResponse.qris,
            ),
          ),
        ],
      ),
    );
  }
}
