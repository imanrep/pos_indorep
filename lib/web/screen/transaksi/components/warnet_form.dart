import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:provider/provider.dart';

class WarnetForm extends StatelessWidget {
  const WarnetForm({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController usernameController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        borderRadius: BorderRadius.circular(12),
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(12),
        // ),
        // elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Transaksi Warnet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                children: [
                  SizedBox(
                    width: 200,
                    child: Consumer<WebTransaksiProvider>(
                      builder: (context, provider, child) {
                        return TextBox(
                          controller: usernameController,
                          placeholder: 'Username',
                          maxLength: 20,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                    height: 50,
                  ),
                  // Package ComboBox
                  Consumer<WebTransaksiProvider>(
                    builder: (context, provider, child) {
                      return ComboBox<String>(
                        value: provider.selectedPackage.nama,
                        placeholder: const Text('Pilih Paket'),
                        items: provider.packages
                            .map((p) => ComboBoxItem<String>(
                                  value: p.nama,
                                  child: Text(
                                      '${p.nama} - ${Helper.rupiahFormatter(p.harga.toDouble())}'),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            provider.setSelectedPackage(
                              provider.packages.firstWhere(
                                (p) => p.nama == val,
                                orElse: () => provider.packages.first,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    width: 12,
                    height: 50,
                  ),
                  Row(
                    children: [
                      Consumer<WebTransaksiProvider>(
                        builder: (context, provider, child) {
                          return Row(
                            children: [
                              RadioButton(
                                checked: provider.selectedMethod == 'Cash',
                                onChanged: (value) {
                                  if (value)
                                    provider.setSSelectedMethod('Cash');
                                },
                                content: const Text('Cash'),
                              ),
                              const SizedBox(width: 12),
                              RadioButton(
                                checked: provider.selectedMethod == 'QRIS',
                                onChanged: (value) {
                                  if (value)
                                    provider.setSSelectedMethod('QRIS');
                                },
                                content: const Text('QRIS'),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 24),
                      Consumer<WebTransaksiProvider>(
                        builder: (context, provider, child) {
                          return FilledButton(
                            onPressed: () async {
                              if (usernameController.text.isNotEmpty) {
                                provider.submitCashierEntry(
                                    usernameController.text);
                                usernameController.clear();
                              } else {
                                await displayInfoBar(context,
                                    builder: (context, close) {
                                  return InfoBar(
                                    title: const Text(
                                        'Username tidak boleh kosong!'),
                                    action: IconButton(
                                      icon: Icon(FluentIcons.clear),
                                      onPressed: close,
                                    ),
                                    severity: InfoBarSeverity.error,
                                  );
                                });
                              }
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  FluentIcons.add,
                                ),
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
