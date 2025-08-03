import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/components/widget/cash_payment_dialog.dart';
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
  GetVoucherDetailsResponse? voucherDetails;
  late String appliedVoucherCode;
  late TextEditingController voucherController;

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

  Future<void> _handlePayment(QrisOrderRequest request,
      List<CartItem> transaction, int grandTotal) async {
    IrepBE irepBE = IrepBE();
    // Handle QRIS payment
    if (request.payment == 'qris') {
      context.loaderOverlay.show();
      QrisOrderResponse response = await irepBE.createOrder(request);
      AddWifiResponse wifiResponse = await irepBE.addWifi();
      if (response.success) {
        TransactionData transactionData = TransactionData(
          orderId: 'IDRPS-${response.orderID}',
          pc: "",
          paymentMethod: request.payment,
          wifiUsername: wifiResponse.wifiUsername,
          wifiPassword: wifiResponse.wifiPassword,
          totalIncome: (response.total * (response.off / 100)).toInt(),
          off: response.off,
          actualAmount: response.total,
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
      final int? cashGiven = await showDialog<int>(
        context: context,
        builder: (context) => CashPaymentDialog(totalAmount: grandTotal),
      );
      if (cashGiven != null && cashGiven >= grandTotal) {
        context.loaderOverlay.show();
        QrisOrderResponse response = await irepBE.createOrder(request);
        AddWifiResponse wifiResponse = await irepBE.addWifi();
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
            wifiUsername: wifiResponse.wifiUsername,
            wifiPassword: wifiResponse.wifiPassword,
            totalIncome: (response.total * (response.off / 100)).toInt(),
            off: response.off,
            actualAmount: response.total,
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
                cashGiven: cashGiven,
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
    }
  }

  @override
  void initState() {
    super.initState();
    voucherController = TextEditingController();
  }

  @override
  void dispose() {
    voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getTotalWithVoucher() {
      final int total = widget.transaction.total.toInt();
      final int off = voucherDetails?.off ?? 0;
      if (off > 0) {
        final double discount = total * (off / 100);
        final int discountedTotal = total - discount.round();
        return Helper.rupiahFormatter(discountedTotal.toDouble());
      }
      return Helper.rupiahFormatter(total.toDouble());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Konfirmasi Pesanan',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurrentOrder(transaction: widget.transaction),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Voucher:',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: voucherController,
                      onChanged: (value) {
                        if (value != value.toUpperCase()) {
                          voucherController.value =
                              voucherController.value.copyWith(
                            text: value.toUpperCase(),
                            selection:
                                TextSelection.collapsed(offset: value.length),
                          );
                        }
                        setState(
                            () {}); // Trigger rebuild to update button state
                      },
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      ],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: IndorepColor.text,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: IndorepColor.text,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: IndorepColor.primary,
                            width: 2,
                          ),
                        ),
                        hintText: 'Kode Voucher',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: voucherController.text.isEmpty
                        ? Colors.grey
                        : IndorepColor.primary,
                    child: IconButton(
                      icon: const Icon(Icons.check, color: Colors.white),
                      onPressed: voucherController.text.isEmpty
                          ? null
                          : () async {
                              var irepBE = IrepBE();
                              var result = await irepBE
                                  .getVoucherDetails(voucherController.text);
                              if (result.success) {
                                Fluttertoast.showToast(
                                  msg:
                                      'Voucher diterapkan, diskon ${result.off}%',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0,
                                );
                                setState(() {
                                  voucherDetails = result;
                                  appliedVoucherCode =
                                      voucherController.text.toUpperCase();
                                });
                              } else {
                                Fluttertoast.showToast(
                                  msg: result.message.isNotEmpty
                                      ? result.message[0].toUpperCase() +
                                          result.message.substring(1)
                                      : result.message,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0,
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
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
              child: Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    voucherDetails != null
                        ? Text(
                            'Voucher "$appliedVoucherCode" diterapkan, diskon ${voucherDetails!.off}%',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 8),
                    Text(
                      'Total : ${getTotalWithVoucher()}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: voucherDetails != null
                            ? Colors.green
                            : Colors.white,
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
                          : () async {
                              var total = voucherDetails != null
                                  ? cartProvider.totalCurrentCart -
                                      (cartProvider.totalCurrentCart *
                                          (voucherDetails!.off / 100))
                                  : cartProvider.totalCurrentCart;
                              var request = QrisOrderRequest(
                                orders: cartProvider.currentOrder,
                                payment: _selectedPaymentMethod!.type,
                                source: 'cafe',
                                voucher: voucherDetails != null
                                    ? voucherController.text
                                    : null,
                              );
                              await _handlePayment(request,
                                  widget.transaction.cart, total.toInt());
                            },
                      onLongPress: () {
                        var request = QrisOrderRequest(
                          orders: cartProvider.currentOrder,
                          payment: _selectedPaymentMethod!.type,
                          source: 'cafe',
                          voucher: voucherDetails != null
                              ? voucherController.text
                              : null,
                        );
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Hi!'),
                                content: Text('${request.toJson()}'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            });
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
                          color: isValidPaymentMethod()
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                );
              }),
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
