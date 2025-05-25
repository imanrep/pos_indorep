import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class PrintingProgressDialog extends StatefulWidget {
  final String device;
  final ReceiptController controller;
  const PrintingProgressDialog({
    super.key,
    required this.device,
    required this.controller,
  });

  @override
  State<PrintingProgressDialog> createState() => _PrintingProgressDialogState();
  static void print(
    BuildContext context, {
    required String device,
    required ReceiptController controller,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: true,
        child: PrintingProgressDialog(
          controller: controller,
          device: device,
        ),
      ),
    );
  }
}

class _PrintingProgressDialogState extends State<PrintingProgressDialog> {
  double? progress;
  Timer? _timeoutTimer;
  bool _isTimeout = false;

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if ((progress ?? 0) == 0) {
        setState(() {
          _isTimeout = true;
        });
      }
    });
    widget.controller.print(
      address: widget.device,
      addFeeds: 5,
      keepConnected: true,
      onProgress: (total, sent) {
        if (mounted) {
          setState(() {
            progress = sent / total;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: SizedBox(
        height: 38,
        child: Row(
          children: [
            Text(
              'Mencetak Struk',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ((progress ?? 0) * 100).round() != 100 && _isTimeout
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
                    onPressed: () async {
                      Navigator.of(context).pop(); // Pop the current dialog
                      await FlutterBluetoothPrinter.disconnect(widget.device);
                    })
                : const SizedBox(),
          ],
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 100,
              maxWidth: 300,
            ),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 16),
          Text('Proses: ${((progress ?? 0) * 100).round()}%',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
      actions: ((progress ?? 0) * 100).round() == 100
          ? [
              ElevatedButton(
                onPressed: () async {
                  await FlutterBluetoothPrinter.disconnect(widget.device);
                  var cartProvider =
                      Provider.of<CartProvider>(context, listen: false);
                  cartProvider.clearCart();
                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // Pop the current dialog
                  // Use a post-frame callback to pop the previous one
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) Navigator.of(context).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (context.mounted) Navigator.of(context).pop();
                    });
                  });
                },
                child: const Text('Selesai'),
              ),
            ]
          : null,
    );
  }
}
