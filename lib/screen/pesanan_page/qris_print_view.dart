import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/components/order_detail_print_view.dart';
import 'package:pos_indorep/services/irepbe_services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrisPrintView extends StatefulWidget {
  final TransactionData transactionData;
  const QrisPrintView({super.key, required this.transactionData});

  @override
  State<QrisPrintView> createState() => _QrisPrintViewState();
}

class _QrisPrintViewState extends State<QrisPrintView> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (_currentPage != page) {
        setState(() {
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      QrisPageOne(
          transactionData: widget.transactionData,
          pageController: _pageController),
      QrisPageTwo(
          transactionData: widget.transactionData,
          pageController: _pageController),
    ];

    return AlertDialog(
      title: Column(
        children: [
          Text("Proses Pesanan",
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(pages.length, (index) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: pages,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class QrisPageOne extends StatefulWidget {
  final TransactionData transactionData;
  final PageController? pageController;
  const QrisPageOne(
      {super.key, required this.transactionData, required this.pageController});

  @override
  State<QrisPageOne> createState() => _QrisPageOneState();
}

class _QrisPageOneState extends State<QrisPageOne> {
  String statusText = "Pending";

  Future<String> getStatus() async {
    IrepBE irepBE = IrepBE();
    GetTransacationsResponse response = await irepBE.getTransactions(1);
    String status = response.data
        .where(
          (transaction) =>
              transaction.orderId == widget.transactionData.orderId,
        )
        .first
        .status;
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final transactionData = widget.transactionData;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              transactionData.orderId,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              transactionData.time,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade200,
              ),
              child: QrImageView(
                data: transactionData.qris ?? '',
                version: QrVersions.auto,
                size: 220.0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'QRIS Payment',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Total : ${Helper.rupiahFormatter(transactionData.total.toDouble())}',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                String status = await getStatus();
                setState(() {
                  statusText = status[0].toUpperCase() +
                      status.substring(1).toLowerCase();
                });
                if (statusText == "Paid") {
                  widget.pageController?.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
                // widget.pageController?.nextPage(
                //   duration: const Duration(milliseconds: 300),
                //   curve: Curves.easeInOut,
                // );
              },
              icon: statusText == "Pending"
                  ? const Icon(Icons.refresh_rounded)
                  : const Icon(Icons.check_circle_rounded),
              label: Text(
                ('Status: $statusText'),
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QrisPageTwo extends StatefulWidget {
  final TransactionData transactionData;
  final PageController? pageController;
  const QrisPageTwo(
      {super.key, required this.transactionData, required this.pageController});

  @override
  State<QrisPageTwo> createState() => _QrisPageTwoState();
}

class _QrisPageTwoState extends State<QrisPageTwo> {
  bool isPrinting = false;
  ReceiptController? controller;
  String statusText = "Pending";
  double? progress;

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

  Future<String> getStatus() async {
    IrepBE irepBE = IrepBE();
    GetTransacationsResponse response = await irepBE.getTransactions(1);
    String status = response.data
        .where(
          (transaction) =>
              transaction.orderId == widget.transactionData.orderId,
        )
        .first
        .status;
    return status;
  }

  @override
  Widget build(BuildContext context) {
    String orderStatus;
    if (widget.transactionData.status == 'cancelled') {
      orderStatus = 'Dibatalkan';
    } else if (widget.transactionData.status == 'pending') {
      orderStatus = 'Pending';
    } else if (widget.transactionData.status == 'paid') {
      orderStatus = 'Sukses';
    } else {
      orderStatus = widget.transactionData.status; // fallback
    }

    final transactionData = widget.transactionData;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: !isPrinting && progress == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) => PopScope(
                              canPop: false,
                              child: OrderDetailPrintView(
                                transaction: widget.transactionData,
                              ),
                            ),
                          );
                        },
                  label: Text('Order Detail',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  icon: Icon(Icons.receipt_long_rounded, size: 20),
                ),
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
                          ? 'Pelanggan'
                          : 'Mencetak Struk ${((progress ?? 0) * 100).round()}%',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  icon: Icon(Icons.print_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 500,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${widget.transactionData.orderId}',
                                      style:
                                          GoogleFonts.robotoMono(fontSize: 18)),
                                  Text(
                                      '${Helper.dateFormatterTwo(widget.transactionData.time)} - ${Helper.timeFormatterTwo(widget.transactionData.time)}',
                                      style:
                                          GoogleFonts.robotoMono(fontSize: 18)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Via: ${widget.transactionData.paymentMethod.toUpperCase()}',
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
                              itemCount: widget.transactionData.items.length,
                              itemBuilder: (context, index) {
                                final cart =
                                    widget.transactionData.items[index];
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            '${option.option} : ${option.value} (+${Helper.rupiahFormatter(option.price.toDouble())})',
                                            style: GoogleFonts.robotoMono(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      cart.note.isNotEmpty
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                'Catatan: ${cart.note}',
                                                style: GoogleFonts.robotoMono(
                                                  fontSize: 14,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Total: ${Helper.rupiahFormatter(widget.transactionData.total.toDouble())}',
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
                            Text(
                              'INDOREP WIFI',
                              style: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "username : ${transactionData.wifiUsername}",
                              style: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              "password : ${transactionData.wifiPassword}",
                              style: GoogleFonts.robotoMono(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),
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
                      onInitialized: (ctrl) =>
                          setState(() => controller = ctrl),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
