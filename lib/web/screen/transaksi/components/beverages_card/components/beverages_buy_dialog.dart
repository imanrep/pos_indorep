import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_indorep/provider/web/warnet_transaksi_provider.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:provider/provider.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/web/model/create_order_kulkas_request.dart';

/// Local UI model for an order line
class _OrderLine {
  int? itemId;
  String? name;
  int price = 0;
  int qty = 1;

  _OrderLine();

  int get lineTotal => (qty <= 0 ? 1 : qty) * price;
}

class BeveragesBuyDialog extends StatefulWidget {
  const BeveragesBuyDialog({super.key});

  @override
  State<BeveragesBuyDialog> createState() => _BeveragesBuyDialogState();
}

class _BeveragesBuyDialogState extends State<BeveragesBuyDialog> {
  bool _isLoading = false;
  final List<_OrderLine> _lines = [_OrderLine()];
  String? _selectedMethod; // "Cash" | "QRIS"

  int get _total {
    return _lines.fold<int>(
        0, (sum, e) => sum + (e.itemId == null ? 0 : e.lineTotal));
  }

  bool _isValid(WarnetTransaksiProvider p) {
    final hasAtLeastOneItem = _lines.any((l) => l.itemId != null && l.qty > 0);
    final methodValid = (_selectedMethod ?? p.selectedMethod).isNotEmpty;
    return hasAtLeastOneItem && methodValid && _total > 0;
  }

  void _addLine() {
    setState(() => _lines.add(_OrderLine()));
  }

  void _removeLine(int index) {
    if (_lines.length == 1) return;
    setState(() => _lines.removeAt(index));
  }

  Future<void> _submit(WarnetTransaksiProvider provider) async {
    if (!_isValid(provider)) return;

    final method = (_selectedMethod ?? provider.selectedMethod);
    setState(() => _isLoading = true);

    try {
      final orders = _lines
          .where((l) => l.itemId != null && l.qty > 0)
          .map((l) => KulkasOrderItem(id: l.itemId!, qty: l.qty))
          .toList();

      final req = CreateOrderKulkasRequest(
        payment: method.toLowerCase(), // "cash" | "qris"
        orders: orders,
      );

      final res = await WarnetBackendServices().createOrderKulkas(request: req);

      // Refresh any needed lists
      provider.getKulkasItem(); // adjust if you have this; or remove

      if (!mounted) return;

      // If QRIS, your backend already displays on-screen QR.
      // Show a heads-up to the operator.
      await displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: const Text('Order kulkas berhasil dibuat'),
          content: Text(
            method.toLowerCase() == 'qris'
                ? 'Silakan scan QRIS di layar. Total: ${Helper.rupiahFormatter(_total.toDouble())}'
                : 'Total: ${Helper.rupiahFormatter(_total.toDouble())}',
          ),
          action:
              IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
          severity: InfoBarSeverity.success,
        );
      });
    } catch (e) {
      if (!mounted) return;
      await displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: const Text('Gagal membuat order'),
          content: Text(e.toString()),
          action:
              IconButton(icon: const Icon(FluentIcons.clear), onPressed: close),
          severity: InfoBarSeverity.error,
        );
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WarnetTransaksiProvider>(
      builder: (context, provider, _) {
        final items =
            provider.kulkasItems; // expect fields: id, name, price, onStock
        final methods = provider.methods; // e.g. ["Cash", "QRIS"]

        return ContentDialog(
          constraints: const BoxConstraints(maxWidth: 500),
          title: const Text('Beli Item Kulkas'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lines
                ..._lines.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final line = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        // Item dropdown
                        ComboBox<int>(
                          placeholder: const Text('Pilih item'),
                          value: line.itemId,
                          items: items
                              .where((it) => it.onStock == true)
                              .map((it) => ComboBoxItem<int>(
                                    value: it.id,
                                    child: Text(
                                        '${it.name} — ${Helper.rupiahFormatter(it.price.toDouble())}'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            final selected =
                                items.firstWhere((it) => it.id == val);
                            setState(() {
                              line.itemId = selected.id;
                              line.name = selected.name;
                              line.price = selected.price;
                            });
                          },
                        ),
                        const SizedBox(width: 8),

                        // Qty
                        SizedBox(
                          width: 100,
                          child: NumberBox<int>(
                            value: line.qty,
                            clearButton: false,
                            min: 1,
                            max: 999,
                            mode: SpinButtonPlacementMode.inline,
                            onChanged: (v) {
                              setState(() => line.qty = (v ?? 1).clamp(1, 999));
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Line total
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            line.itemId == null
                                ? '-'
                                : Helper.rupiahFormatter(
                                    line.lineTotal.toDouble()),
                            style:
                                FluentTheme.of(context).typography.bodyStrong,
                          ),
                        ),
                        const SizedBox(width: 12),

                        IconButton(
                          icon: const Icon(FluentIcons.chrome_close, size: 14),
                          onPressed: _lines.length == 1
                              ? null
                              : () => _removeLine(idx),
                        ),
                      ],
                    ),
                  );
                }),

                // Add another line
                Align(
                  alignment: Alignment.centerLeft,
                  child: Button(
                    onPressed: _isLoading ? null : _addLine,
                    child: const Text('+ Tambah Item'),
                  ),
                ),

                const SizedBox(height: 12),

                // Payment method
                Row(
                  children: [
                    ComboBox<String>(
                      value: _selectedMethod ??
                          (provider.selectedMethod.isEmpty
                              ? null
                              : provider.selectedMethod),
                      placeholder: const Text('Metode pembayaran'),
                      items: methods
                          .map((m) =>
                              ComboBoxItem<String>(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedMethod = v);
                        provider.setSelectedMethod(v ?? '');
                      },
                    ),
                    const SizedBox(width: 12),

                    // Total
                    InfoLabel(
                      label: 'Total',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          Helper.rupiahFormatter(_total.toDouble()),
                          style: FluentTheme.of(context)
                              .typography
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Button(
                child: const Text('Kembali'),
                onPressed: _isLoading
                    ? null
                    : () async {
                        Navigator.pop(context);
                        var services = WarnetBackendServices();
                        await services.resetDisplay();
                      }),
            FilledButton(
              onPressed: _isLoading || !_isValid(provider)
                  ? null
                  : () => _submit(provider),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: ProgressRing(strokeWidth: 3))
                  : const Text('Buat Order'),
            ),
          ],
        );
      },
    );
  }
}
