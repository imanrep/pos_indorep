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
  late TextEditingController nameController;

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
      final name = await showDialog(
        context: context,
        builder: (context) => nameInputDialog(context),
      );
      if (name == null || name.isEmpty) {
        return;
      } else {
        context.loaderOverlay.show();
        QrisOrderResponse response = await irepBE.createOrder(request);
        AddWifiResponse wifiResponse = await irepBE.addWifi();
        if (response.success) {
          TransactionData transactionData = TransactionData(
            orderId: 'IDRPS-${response.orderID}',
            nama: name,
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
      }
      // Handle Cash payment
    } else if (request.payment == 'cash') {
      final name = await showDialog(
        context: context,
        builder: (context) => nameInputDialog(context),
      );
      if (name == null || name.isEmpty) {
        return;
      } else {
        final int? cashGiven = await showDialog<int>(
          context: context,
          builder: (context) => CashPaymentDialog(totalAmount: grandTotal),
        );
        if (cashGiven != null && cashGiven >= grandTotal) {
          context.loaderOverlay.show();
          QrisOrderResponse response = await irepBE.createOrder(request);
          AddWifiResponse wifiResponse = await irepBE.addWifi();
          if (response.success) {
            var mainProvider =
                Provider.of<MainProvider>(context, listen: false);
            Uint8List openDrawerCommand =
                Uint8List.fromList([27, 112, 0, 100, 250]);
            FlutterBluetoothPrinter.printBytes(
                address: mainProvider.printerAddress,
                keepConnected: false,
                data: openDrawerCommand);
            TransactionData transactionData = TransactionData(
              orderId: 'IDRPS-${response.orderID}',
              nama: name,
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
  }

  @override
  void initState() {
    super.initState();
    voucherController = TextEditingController();
    nameController = TextEditingController();
  }

  @override
  void dispose() {
    voucherController.dispose();
    nameController.dispose();
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        : GestureDetector(
                            onTap: () async {
                              String capitalize(String s) => s.isNotEmpty
                                  ? '${s[0].toUpperCase()}${s.substring(1)}'
                                  : s;
                              final result = await showDialog(
                                context: context,
                                builder: (context) => vocInputDialog(context),
                              );

                              if (result != null) {
                                if (result.success) {
                                  setState(() {
                                    voucherDetails = result;
                                    appliedVoucherCode =
                                        voucherController.text.toUpperCase();
                                  });
                                  Fluttertoast.showToast(
                                      msg: capitalize("Voucher diterapkan!"));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: capitalize(result.message));
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    IndorepColor.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: IndorepColor.primary),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sell_rounded,
                                    color: IndorepColor.primary,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Punya Voucher?',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: IndorepColor.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
                        'Lanjut',
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

  AlertDialog nameInputDialog(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Nama Pelanggan', style: GoogleFonts.inter()),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => Navigator.pop(context, null), // return null if closed
            child: const CircleAvatar(child: Icon(Icons.close)),
          )
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: nameController,
                onChanged: (value) {
                  if (value != value.toUpperCase()) {
                    nameController.value = nameController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  }
                },
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-z 0-9]')),
                ],
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Ujang Abdul Jabar',
                  hintStyle: GoogleFonts.inter(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: nameController,
              builder: (context, value, _) {
                return CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      value.text.isEmpty ? Colors.grey : IndorepColor.primary,
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: value.text.isEmpty
                        ? null
                        : () {
                            Navigator.pop(context, nameController.text);
                          },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  AlertDialog vocInputDialog(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Input Voucher', style: GoogleFonts.inter()),
          GestureDetector(
            onTap: () => Navigator.pop(context, null), // return null if closed
            child: const CircleAvatar(child: Icon(Icons.close)),
          )
        ],
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: voucherController,
                onChanged: (value) {
                  if (value != value.toUpperCase()) {
                    voucherController.value = voucherController.value.copyWith(
                      text: value.toUpperCase(),
                      selection: TextSelection.collapsed(offset: value.length),
                    );
                  }
                },
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-z0-9]')),
                ],
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'IDRPV1A2B',
                  hintStyle: GoogleFonts.inter(fontStyle: FontStyle.italic),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: voucherController,
              builder: (context, value, _) {
                return CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      value.text.isEmpty ? Colors.grey : IndorepColor.primary,
                  child: IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: value.text.isEmpty
                        ? null
                        : () async {
                            var irepBE = IrepBE();
                            GetVoucherDetailsResponse res =
                                await irepBE.getVoucherDetails(value.text);
                            Navigator.pop(context, res);
                          },
                  ),
                );
              },
            ),
          ],
        ),
      ),
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
