import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';

class CashPaymentDialog extends StatefulWidget {
  final int totalAmount;

  const CashPaymentDialog({super.key, required this.totalAmount});

  @override
  State<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  String _cashInput = '';

  int get _cashGiven => int.tryParse(_cashInput) ?? 0;
  int get _kembalian => _cashGiven - widget.totalAmount;

  void _onKeyboardTap(String value) {
    setState(() {
      if (value == 'C') {
        _cashInput = '';
      } else if (value == '←') {
        _cashInput = _cashInput.isNotEmpty
            ? _cashInput.substring(0, _cashInput.length - 1)
            : '';
      } else {
        _cashInput += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        MediaQuery.of(context).size.height * 0.85; // 85% of screen height

    return AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Pembayaran: ${Helper.rupiahFormatter(widget.totalAmount.toDouble())}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                'Uang Diberikan:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  Helper.rupiahFormatter(_cashGiven.toDouble()),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kembalian:',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                _kembalian < 0
                    ? 'Rp0'
                    : Helper.rupiahFormatter(_kembalian.toDouble()),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),
              _buildNumberPad(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _cashGiven >= widget.totalAmount
              ? () => Navigator.pop(context, _cashGiven)
              : null,
          child: const Text('Lanjutkan'),
        ),
      ],
    );
  }

  Widget _buildNumberPad() {
    final buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '←'],
    ];

    return Column(
      children: buttons.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((char) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                width: 70,
                height: 60,
                child: OutlinedButton(
                  onPressed: () => _onKeyboardTap(char),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: IndorepColor.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(char, style: const TextStyle(fontSize: 20)),
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
