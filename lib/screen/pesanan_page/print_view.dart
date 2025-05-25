import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/helper/printing_progress_dialog.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PrintView extends StatefulWidget {
  final TransactionData transaction;
  final ReceiptController? controller;
  const PrintView({super.key, required this.transaction, this.controller});

  @override
  State<PrintView> createState() => _PrintViewState();
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

class _PrintViewState extends State<PrintView> {
  bool isPrinting = false;
  ReceiptController? controller;
  double? progress;
  @override
  void initState() {
    super.initState();
  }

  Future<void> _startPrint() async {
    final provider = Provider.of<MainProvider>(context, listen: false);
    final address = provider.printerAddress;

    if (address.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Tidak ada printer yang terhubung',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    controller!.print(
      address: address,
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
    String orderStatus;
    if (widget.transaction.status == 'cancelled') {
      orderStatus = 'Dibatalkan';
    } else if (widget.transaction.status == 'pending') {
      orderStatus = 'Pending';
    } else if (widget.transaction.status == 'paid') {
      orderStatus = 'Sukses';
    } else {
      orderStatus = widget.transaction.status; // fallback
    }

    return AlertDialog(
      title: Row(
        children: [
          Text('Transaksi Berhasil',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const Spacer(),
          IconButton(
            onPressed: () {
              var transasctionProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              transasctionProvider.clearSelectedTransaction();
              var cartProvider =
                  Provider.of<CartProvider>(context, listen: false);
              cartProvider.clearCart();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            icon: Opacity(
                opacity: isPrinting ? 1 : 0,
                child: CircleAvatar(
                    child: const Icon(Icons.close_rounded, size: 20))),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Receipt(
                defaultTextStyle: GoogleFonts.robotoMono(),
                backgroundColor: Colors.white,
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('INDOREP GAMING & CAFFE',
                          style: GoogleFonts.robotoMono(
                              fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text('Jl. Margonda No. 386, Beji, Depok',
                          style: GoogleFonts.robotoMono(fontSize: 16)),
                      const SizedBox(height: 24),
                      Text('--------------------------------',
                          style: GoogleFonts.robotoMono(fontSize: 18)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${widget.transaction.orderId}',
                                style: GoogleFonts.robotoMono(fontSize: 18)),
                            Text(
                                '${Helper.dateFormatterTwo(widget.transaction.time)} - ${Helper.timeFormatterTwo(widget.transaction.time)}',
                                style: GoogleFonts.robotoMono(fontSize: 18)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Via: ${widget.transaction.paymentMethod.toUpperCase()}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Status: ${orderStatus.toUpperCase()}',
                              style: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('--------------------------------',
                          style: GoogleFonts.robotoMono(fontSize: 18)),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Pesanan:',
                          style: GoogleFonts.robotoMono(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.transaction.items.length,
                        itemBuilder: (context, index) {
                          final cart = widget.transaction.items[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              cart.name,
                              style: GoogleFonts.robotoMono(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${cart.qty} x ${Helper.rupiahFormatter(cart.subTotal.toDouble())}',
                                  style: GoogleFonts.robotoMono(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                for (var option in cart.option)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                      '${option.option} : ${option.value} (+${Helper.rupiahFormatter(option.price.toDouble())})',
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: ${Helper.rupiahFormatter(widget.transaction.total.toDouble())}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Info, saran, dan masukan',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        'business@indorep.com',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: QrImageView(
                          data: "https://youtu.be/dQw4w9WgXcQ",
                          version: QrVersions.auto,
                          size: 120.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Terima Kasih!',
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          height: 150,
                        ),
                      ),
                    ],
                  );
                },
                onInitialized: (ctrl) => setState(() => controller = ctrl),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton.icon(
          onPressed: () async {
            if (controller == null) {
              Fluttertoast.showToast(
                msg: 'Printer belum siap!',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
              return;
            }
            setState(() {
              isPrinting = true;
            });
            await _startPrint();
          },
          label: Text(
              !isPrinting
                  ? 'Cetak'
                  : 'Mencetak Struk ${((progress ?? 0) * 100).round()}%',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          icon: Icon(Icons.print_rounded, size: 20),
        ),
      ],
    );
  }
}
