import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:provider/provider.dart';

class BeveragesForm extends StatelessWidget {
  const BeveragesForm({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController qtyController = TextEditingController(text: '1');
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Beverages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Beverages ComboBox
                  Consumer<WebTransaksiProvider>(
                    builder: (context, provider, child) {
                      return ComboBox<String>(
                        value: provider.selectedBeverages,
                        placeholder: const Text('Pilih Item'),
                        items: provider.beverages
                            .map((bev) => ComboBoxItem<String>(
                                  value: bev.nama,
                                  child: Text(
                                      '${bev.nama} - ${Helper.rupiahFormatter(bev.harga.toDouble())}'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            provider.setSelectedBeverages(val);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 12, height: 50),
                  SizedBox(
                    width: 100,
                    child: NumberBox(
                      clearButton: false,
                      value: int.tryParse(qtyController.text)!.clamp(1, 99),
                      min: 1,
                      max: 99,
                      mode: SpinButtonPlacementMode.inline,
                      placeholder: 'Qty',
                      onChanged: (value) {
                        final safeValue = (value ?? 1).clamp(1, 99);
                        qtyController.text = safeValue.toString();
                      },
                    ),
                  ),
                  const SizedBox(width: 12, height: 64),
                  // Payment Method RadioButtons
                  Consumer<WebTransaksiProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioButton(
                            checked: provider.selectedMethod == 'Cash',
                            onChanged: (value) {
                              if (value) provider.setSSelectedMethod('Cash');
                            },
                            content: const Text('Cash'),
                          ),
                          const SizedBox(width: 12),
                          RadioButton(
                            checked: provider.selectedMethod == 'QRIS',
                            onChanged: (value) {
                              if (value) provider.setSSelectedMethod('QRIS');
                            },
                            content: const Text('QRIS'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  // Add Button
                  Consumer<WebTransaksiProvider>(
                    builder: (context, provider, child) {
                      return FilledButton(
                        onPressed: () async {
                          provider.submitBeveragesEntry(qtyController.text);
                          qtyController.clear();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FluentIcons.add),
                            const SizedBox(width: 8),
                            Text(
                              'Tambah',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
