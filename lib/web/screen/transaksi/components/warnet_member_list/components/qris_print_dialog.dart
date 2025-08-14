import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/web/model/create_member_response.dart';
import 'package:pos_indorep/web/model/web_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrisPrintDialog extends StatefulWidget {
  final CreateMemberResponse response;
  final WarnetPaket paket;
  const QrisPrintDialog({super.key, required this.response, required this.paket});

  @override
  State<QrisPrintDialog> createState() => _QrisPrintDialogState();
}

class _QrisPrintDialogState extends State<QrisPrintDialog> {
  final _ftp = FlutterThermalPrinter.instance;

  // Hardcoded printer details
  final String _vendorId = "XXXX"; // Replace with your printer's vendorId
  final String _productId = "YYYY"; // Replace with your printer's productId

  Printer? _selectedPrinter;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  Future<void> _initializePrinter() async {
    // Manually create a Printer object with the vendorId and productId
    _selectedPrinter = Printer(
      name: "Kassen Thermal Printer",
      connectionType: ConnectionType.USB,
      vendorId: _vendorId,
      productId: _productId,
    );

    // Attempt to connect to the printer
    try {
      await _ftp.connect(_selectedPrinter!);
    } catch (e) {
      debugPrint("Failed to connect to printer: $e");
    }
  }


  Future<void> _printUsb() async {
  if (_selectedPrinter == null) {
    debugPrint("Printer not initialized.");
    return;
  }

  try {
    setState(() => _isPrinting = true);

    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final List<int> bytes = [];

    final orderType = widget.response.qris.isEmpty ? 'Cash' : 'QRIS';
    final now = DateTime.now();
    final formattedDate = Helper.dateFormatterTwo(now.toIso8601String());
    final formattedTime = Helper.timeFormatterTwo(now.toIso8601String());

    // HEADER
    bytes.addAll(generator.text(
      'INDOREP GAMING & CAFFE',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    ));

    bytes.addAll(generator.feed(1));


    bytes.addAll(generator.text(
      'Jl. Margonda No. 386, Beji, Kota Depok',
      styles: const PosStyles(align: PosAlign.center),
    ));

    bytes.addAll(generator.hr());

    // ORDER INFO
    bytes.addAll(generator.row([
      PosColumn(
        text: 'IDRPW-${widget.response.orderID}',
        width: 5,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: '$formattedDate $formattedTime',
        width: 7,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    bytes.addAll(generator.row([
      PosColumn(
        text: widget.paket.nama,
        width: 6,
        styles: const PosStyles(align: PosAlign.left),
      ),
      PosColumn(
        text: 'Via: $orderType',
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]));

    bytes.addAll(generator.hr());

     bytes.addAll(generator.text(
      'INDOREP Net Account:',
      styles: const PosStyles(align: PosAlign.left),
    ));

    bytes.addAll(generator.feed(1));

    // USER INFO
    bytes.addAll(generator.text(
      'Username: ${widget.response.username}',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    ));

    bytes.addAll(generator.text(
      'Password: ${widget.response.password}',
      styles: const PosStyles(bold: true, align: PosAlign.center),
    ));

    bytes.addAll(generator.feed(1));

    // NOTICE
    bytes.addAll(generator.text(
      'dapat digunakan juga pada WiFi',
      styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1),
    ));
     bytes.addAll(generator.text(
      'yang tersedia',
      styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size1, width: PosTextSize.size1),
    ));
    bytes.addAll(generator.text(
      'INDOREP-WARNET dan INDOREP-NET',
      styles: const PosStyles(align: PosAlign.center),
    ));
    

    // temporary, enable qris via receipt
    if(orderType == 'QRIS') {
      String qrData = widget.response.qris;
      const double qrSize = 340;
    bytes.addAll(generator.feed(1));
      try {
  final uiImg = await QrPainter(
    data: qrData,
    version: QrVersions.auto,
    gapless: false,
  ).toImageData(qrSize);
  final dir = await getTemporaryDirectory();
  final pathName = '${dir.path}/qr_tmp.png';
  final qrFile = File(pathName);
  final imgFile = await qrFile.writeAsBytes(uiImg!.buffer.asUint8List());
  final img = decodeImage(imgFile.readAsBytesSync());

  bytes.addAll(generator.image(img!));
} catch (e) {
  print(e);
}
    }

    bytes.addAll(generator.feed(1));

    // // QR CODE
    // if (widget.response.qris.isNotEmpty) {
    //   bytes.addAll(generator.qrcode(widget.response.qris));
    //   bytes.addAll(generator.feed(1));
    // }

    // TOTAL
    bytes.addAll(generator.text(
      'Total: ${Helper.rupiahFormatter(widget.paket.harga.toDouble())}',
      styles: const PosStyles(
        bold: true,
        align: PosAlign.right,
      ),
    ));

    bytes.addAll(generator.feed(1));

    // FOOTER
    bytes.addAll(generator.text(
      'Info, saran, dan masukan',
      styles: const PosStyles(align: PosAlign.center),
    ));
    bytes.addAll(generator.text(
      'business@indorep.com',
      styles: const PosStyles(align: PosAlign.center),
    ));

    bytes.addAll(generator.feed(1));

    bytes.addAll(generator.text(
      'Terima Kasih!',
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
      ),
    ));
    bytes.addAll(generator.cut());

    // SEND TO PRINTER
    await _ftp.printData(_selectedPrinter!, bytes);
  } catch (e) {
    debugPrint("Print error: $e");
    await displayInfoBar(context, builder: (ctx, close) {
      return InfoBar(
        title: const Text('Gagal mencetak'),
        content: Text(e.toString()),
        action: IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
        severity: InfoBarSeverity.error,
      );
    });
  } finally {
    if (mounted) setState(() => _isPrinting = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final orderType = widget.response.qris.isEmpty ? 'Cash' : 'QRIS';

    return ContentDialog(
      constraints: BoxConstraints(
        maxWidth: 450,
        maxHeight: 650,
      ),
      title: Text('Konfirmasi Pembayaran $orderType'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(
                'IDRPW-${widget.response.orderID}',
                style: FluentTheme.of(context).typography.body!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                '${Helper.dateFormatterTwo(DateTime.now().toIso8601String())} ${Helper.timeFormatterTwo(DateTime.now().toIso8601String())}',
                 style: FluentTheme.of(context).typography.body!.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,)
              ),
              ],),
              const SizedBox(height: 4),
               Row(children: [
                Text(
                widget.response.username,
                style: FluentTheme.of(context).typography.body!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.paket.nama} (${Helper.rupiahFormatter(widget.paket.harga.toDouble())})',
                 style: FluentTheme.of(context).typography.body!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,)
              ),
              ],),
              const SizedBox(height: 16),
              if(widget.response.qris.isEmpty)
                Center(
                  child: Text(
                    'Silakan lakukan pembayaran melalui kasir.',
                    style: FluentTheme.of(context).typography.body!.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                )
              else
              Column(
                children: [
                  Center(
                    child: Text(
                      'Silakan lakukan pembayaran melalui QRIS berikut:',
                      style: FluentTheme.of(context).typography.body!.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Card(
                  padding: const EdgeInsets.all(8.0),
                  backgroundColor: Colors.white,
                  child: QrImageView(
                    data: widget.response.qris,
                    version: QrVersions.auto,
                    size: 200.0,
                    gapless: false,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '${Helper.rupiahFormatter(widget.paket.harga.toDouble())}',
                  style: FluentTheme.of(context).typography.body!.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
                ],
              ),
              
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: const Text('Close'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          child: _isPrinting ? const Text('Printing...') : const Text('Print'),
          onPressed: _isPrinting ? null : _printUsb,
        ),
      ],
    );
  }
}