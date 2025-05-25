import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/print_view.dart';
import 'package:pos_indorep/screen/pesanan_page/qris_print_view.dart';
import 'package:pos_indorep/services/irepbe_services.dart';
import 'package:provider/provider.dart';

class PaymentDialogBottomSheet extends StatefulWidget {
  final TransactionModel transaction;

  const PaymentDialogBottomSheet({
    super.key,
    required this.transaction,
  });

  @override
  State<PaymentDialogBottomSheet> createState() =>
      _PaymentDialogBottomSheetState();
}

class _PaymentDialogBottomSheetState extends State<PaymentDialogBottomSheet> {
  final List<PaymentButton> _paymentMethods = [
    PaymentButton(
      name: 'Cash',
      image: 'assets/images/cash.png',
      type: 'cash',
    ),
    PaymentButton(
      name: 'QRIS',
      image: 'assets/images/qris.png',
      type: 'qris',
    ),
  ];

  PaymentButton? _selectedPaymentMethod;

  bool isValidPaymentMethod() {
    return _selectedPaymentMethod != null;
  }

  Future<void> _handlePayment(
      QrisOrderRequest request, List<CartItem> transaction) async {
    IrepBE irepBE = IrepBE();
    // Handle QRIS payment
    if (request.payment == 'qris') {
      context.loaderOverlay.show();
      QrisOrderResponse response = await irepBE.createOrder(request);
      if (response.success) {
        TransactionData transactionData = TransactionData(
          orderId: 'IDRPS-${response.orderID}',
          pc: "",
          paymentMethod: request.payment,
          total: response.total,
          status: response.success ? 'paid' : 'pending',
          time: response.time,
          qris: response.qris,
          items: transaction.map((cart) {
            return TransactionItem(
                name: cart.menuName,
                note: cart.notes,
                option: [
                  for (final option in cart.selectedOptions)
                    for (final optVal
                        in option.optionValue.where((v) => v.isSelected))
                      TransactionMenuOption(
                        option: option.optionName,
                        value: optVal.optionValueName,
                        price: optVal.optionValuePrice,
                      ),
                ],
                qty: cart.qty,
                subTotal: cart.menuPrice);
          }).toList(),
        );
        context.loaderOverlay.hide();
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => PopScope(
              canPop: false,
              child: QrisPrintView(
                transactionData: transactionData,
              )),
        );
      }

      // Handle Cash payment
    } else if (request.payment == 'cash') {
      // debugPrint(request.toJson().toString());
      context.loaderOverlay.show();
      QrisOrderResponse response = await irepBE.createOrder(request);
      if (response.success) {
        var mainProvider = Provider.of<MainProvider>(context, listen: false);
        Uint8List openDrawerCommand =
            Uint8List.fromList([27, 112, 0, 100, 250]);
        FlutterBluetoothPrinter.printBytes(
            address: mainProvider.printerAddress,
            keepConnected: false,
            data: openDrawerCommand);
        TransactionData transactionData = TransactionData(
          orderId: 'IDRPS-${response.orderID}',
          pc: "",
          paymentMethod: request.payment,
          total: response.total,
          status: response.success ? 'paid' : 'pending',
          time: response.time,
          items: transaction.map((cart) {
            return TransactionItem(
                name: cart.menuName,
                note: cart.notes,
                option: [
                  for (final option in cart.selectedOptions)
                    for (final optVal
                        in option.optionValue.where((v) => v.isSelected))
                      TransactionMenuOption(
                        option: option.optionName,
                        value: optVal.optionValueName,
                        price: optVal.optionValuePrice,
                      ),
                ],
                qty: cart.qty,
                subTotal: cart.menuPrice);
          }).toList(),
        );
        context.loaderOverlay.hide();
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => PopScope(
            canPop: false,
            child: PrintView(
              transaction: transactionData,
            ),
          ),
        );
      } else {
        // Handle failed payment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${response.message}'),
          ),
        );
      }
    }
    //   if (response.success) {

    //     Navigator.pop(context);
    //   } else {
    //     // Handle failed payment
    //     // Implement your failure logic here
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Payment failed: ${response.message}'),
    //       ),
    //     );
    // }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Konfirmasi Pesanan',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurrentOrder(transaction: widget.transaction),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      persistentFooterAlignment: AlignmentDirectional.centerStart,
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Metode pembayaran :',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: _paymentMethods.map((method) {
                        return _buildPaymentMethodButton(
                          method,
                          _selectedPaymentMethod == method,
                          () {
                            setState(() {
                              _selectedPaymentMethod = method;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Total : ${Helper.rupiahFormatter(widget.transaction.total.toDouble())}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(150, 50),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      backgroundColor: IndorepColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _selectedPaymentMethod == null
                        ? null
                        : () {
                            CartProvider cartProvider =
                                Provider.of<CartProvider>(context,
                                    listen: false);
                            var request = QrisOrderRequest(
                                orders: cartProvider.currentOrder,
                                payment: _selectedPaymentMethod!.type,
                                source: 'cafe');
                            _handlePayment(request, widget.transaction.cart);
                          },
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color:
                          isValidPaymentMethod() ? Colors.white : Colors.grey,
                    ),
                    label: Text(
                      'Bayar',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color:
                            isValidPaymentMethod() ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CurrentOrder extends StatelessWidget {
  final TransactionModel transaction;
  const CurrentOrder({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pesanan:',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: transaction.cart.length,
          itemBuilder: (context, index) {
            final cart = transaction.cart[index];
            return ListTile(
              dense: true,
              leading: Text(
                '${index + 1}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              title: Text(
                cart.menuName,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cart.qty} x ${Helper.rupiahFormatter(cart.menuPrice.toDouble())}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...cart.selectedOptions.map((option) => Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: option.optionValue
                              .where((optVal) => optVal.isSelected)
                              .map((optVal) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, bottom: 2.0),
                                    child: Text(
                                      "- ${optVal.optionValueName} (+${Helper.rupiahFormatter(optVal.optionValuePrice.toDouble())})",
                                      style: GoogleFonts.inter(
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ))
                              .toList(),
                        ),
                      )),
                  const SizedBox(height: 8),
                  Text(
                    '${cart.notes}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                Helper.rupiahFormatter(cart.subTotal),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildPaymentMethodButton(
    PaymentButton method, bool isSelected, VoidCallback onTap) {
  return InkWell(
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? IndorepColor.primary.withOpacity(0.8) : Colors.white70,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            width: 2,
            color: isSelected ? IndorepColor.primary : Colors.transparent),
      ),
      child: Column(
        children: [
          Image.asset(
            method.image,
            width: 50,
            height: 20,
          ),
          const SizedBox(height: 8),
          Text(
            method.name,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
