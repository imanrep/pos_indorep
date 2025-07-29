import 'package:flutter/material.dart';
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: IndorepColor.primary, width: 1.5),
        ),
        elevation: 2,
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
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Username TextField
                  Consumer<WebTransaksiProvider>(
                      builder: (context, provider, child) {
                    return Expanded(
                      flex: 3,
                      child: TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          counterText: "",
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLength: 20,
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  // Package Dropdown
                  Expanded(
                    flex: 4,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Paket',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12), // Match TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Consumer<WebTransaksiProvider>(
                          builder: (context, provider, child) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.selectedPackage.nama,
                            isExpanded: true,
                            isDense: true,
                            onChanged: (val) {
                              provider.setSelectedPackage(provider.packages
                                  .firstWhere((p) => p.nama == val,
                                      orElse: () => provider.packages.first));
                            },
                            items: provider.packages
                                .map((p) => DropdownMenuItem<String>(
                                      value: p.nama,
                                      child: Text(
                                          '${p.nama} - ${Helper.rupiahFormatter(p.harga.toDouble())}'),
                                    ))
                                .toList(),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Metode',
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12), // Match TextField
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                      child: Consumer<WebTransaksiProvider>(
                          builder: (context, provider, child) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.selectedMethod,
                            isExpanded: true,
                            isDense: true,
                            onChanged: (val) =>
                                provider.setSSelectedMethod(val!),
                            items: provider.methods
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<WebTransaksiProvider>(
                  builder: (context, provider, child) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Material(
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: IndorepColor.primary,
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        if (usernameController.text.isNotEmpty) {
                          provider.submitCashierEntry(usernameController.text);
                          usernameController.clear();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Username tidak boleh kosong',
                                style: GoogleFonts.inter(),
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tambah',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })
            ],
          ),
        ),
      ),
    );
  }
}
