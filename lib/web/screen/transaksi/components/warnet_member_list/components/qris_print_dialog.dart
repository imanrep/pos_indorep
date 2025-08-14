import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/web/model/create_member_response.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrisPrintDialog extends StatefulWidget {
  final CreateMemberResponse response;
  const QrisPrintDialog({super.key, required this.response});

  @override
  State<QrisPrintDialog> createState() => _QrisPrintDialogState();
}

class _QrisPrintDialogState extends State<QrisPrintDialog> {
  final _ftp = FlutterThermalPrinter.instance;

  List<Printer> _printers = [];
  Printer? _selectedPrinter;
  StreamSubscription<List<Printer>>? _scanSub;

  bool _isPrinting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _scanUsbPrinters();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _ftp.stopScan();
    super.dispose();
  }

  Future<void> _scanUsbPrinters() async {
    setState(() => _isScanning = true);
    _scanSub?.cancel();

    // Triggers a fresh enumeration; results come via devicesStream
    await _ftp.getPrinters(connectionTypes: [ConnectionType.USB]);

    _scanSub = _ftp.devicesStream.listen((devices) {
      setState(() {
        _printers = devices
            .where((p) => p.connectionType == ConnectionType.USB)
            .toList();
        _selectedPrinter ??= _printers.isNotEmpty ? _printers.first : null;
        _isScanning = false;
      });
    });
  }

  Future<void> _connectSelected() async {
    if (_selectedPrinter == null) return;
    final already = _selectedPrinter!.isConnected ?? false;
    if (!already) {
      await _ftp.connect(_selectedPrinter!);
    }
  }

  /// Your existing receipt layout extracted to a reusable method (for preview & printing)
  Widget _buildReceipt() {
    final orderType = widget.response.qris.isEmpty ? 'Cash' : 'QRIS';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('INDOREP GAMING & CAFFE',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(
                fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Jl. Margonda No. 386, Beji, Kota Depok',
            textAlign: TextAlign.center,
            style: GoogleFonts.robotoMono(fontSize: 18)),
        const SizedBox(height: 24),
        Text('----------------------------------------------------------------',
            style: GoogleFonts.robotoMono(fontSize: 18)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IDRPW-${widget.response.orderID}',
                  style: GoogleFonts.robotoMono(fontSize: 18)),
              Text(
                '${Helper.dateFormatterTwo(DateTime.now().toIso8601String())} - '
                '${Helper.timeFormatterTwo(DateTime.now().toIso8601String())}',
                style: GoogleFonts.robotoMono(fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUKSES',
                  style: GoogleFonts.robotoMono(
                      fontSize: 18, fontWeight: FontWeight.w400)),
              Text('Via: $orderType',
                  style: GoogleFonts.robotoMono(
                      fontSize: 18, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        Text('----------------------------------------------------------------',
            style: GoogleFonts.robotoMono(fontSize: 18)),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Username: ${widget.response.username}',
              style: GoogleFonts.robotoMono(
                  fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Password: ${widget.response.password}',
              style: GoogleFonts.robotoMono(
                  fontSize: 18, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Username dan Password dapat digunakan juga pada SSID WiFi gedung kami @INDOREP-WARNET dan @INDOREP-NET',
            style: GoogleFonts.robotoMono(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 16),
        if (widget.response.qris.isNotEmpty)
          Center(
            child: QrImageView(
              data: widget.response.qris,
              version: QrVersions.auto,
              size: 120.0,
            ),
          ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Total: ${Helper.rupiahFormatter(10000.toDouble())}',
            style: GoogleFonts.robotoMono(
                fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 32),
        Text('Info, saran, dan masukan',
            style: GoogleFonts.robotoMono(
                fontSize: 18, fontWeight: FontWeight.w400)),
        Text('business@indorep.com',
            style: GoogleFonts.robotoMono(
                fontSize: 18, fontWeight: FontWeight.w400)),
        const SizedBox(height: 24),
        Text('Terima Kasih!',
            style: GoogleFonts.robotoMono(
                fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Simplest USB print: render widget -> send via USB
  Future<void> _printUsb() async {
    if (_selectedPrinter == null) {
      await _scanUsbPrinters();
      if (_selectedPrinter == null) {
        await displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: const Text('Tidak ada printer'),
            content: const Text(
                'Pastikan printer USB terpasang & driver terinstal.'),
            action: IconButton(
                icon: const Icon(FluentIcons.clear), onPressed: close),
            severity: InfoBarSeverity.warning,
          );
        });
        return;
      }
    }

    try {
      setState(() => _isPrinting = true);

      await _connectSelected();

      // printOnBle must be false for USB
      await _ftp.printWidget(
        context,
        printer: _selectedPrinter!,
        printOnBle: false,
        widget: FluentTheme(
          data: FluentTheme.of(context), // reuse current Fluent theme
          child: Directionality(
            textDirection: Directionality.of(context), // inherit text direction
            child: Container(
              color: Colors.white, // solid background for clean capture
              padding: const EdgeInsets.all(16),
              child: _buildReceipt(), // your existing Fluent-based receipt
            ),
          ),
        ),
      );

      await displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: const Text('Berhasil mencetak'),
          action:
              IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
          severity: InfoBarSeverity.success,
        );
      });
    } catch (e) {
      await displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: const Text('Gagal mencetak'),
          content: Text(e.toString()),
          action:
              IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
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
      title: Text('Pembayaran $orderType - ${widget.response.username}'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Printer picker row
          Row(
            children: [
              const Text('Printer:'),
              const SizedBox(width: 12),
              Expanded(
                child: ComboBox<Printer>(
                  isExpanded: true,
                  value: _selectedPrinter,
                  items: _printers.map((p) {
                    final name =
                        p.name?.isNotEmpty == true ? p.name! : 'USB Printer';
                    return ComboBoxItem(
                      value: p,
                      child: Text(
                          '$name  ${p.vendorId ?? ""}:${p.productId ?? ""}'),
                    );
                  }).toList(),
                  onChanged: (p) => setState(() => _selectedPrinter = p),
                ),
              ),
              const SizedBox(width: 8),
              Button(
                onPressed: _isScanning ? null : _scanUsbPrinters,
                child: _isScanning
                    ? const Text('Scanning...')
                    : const Text('Rescan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Receipt preview (scrollable)
          Expanded(
            child: SingleChildScrollView(
              child: _buildReceipt(),
            ),
          ),
        ],
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
