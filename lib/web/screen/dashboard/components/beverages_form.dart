import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:pos_indorep/web/model/web_model.dart';
import 'package:provider/provider.dart';

class BeveragesForm extends StatelessWidget {
  const BeveragesForm({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController _selectedBeveragesQtyController =
        TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child:
          Consumer<WebTransaksiProvider>(builder: (context, provider, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: IndorepColor.primary, width: 1.5),
          ),
          elevation: 2,
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Beverages',
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
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Item',
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
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            isDense: true,
                            value: provider.selectedBeverages,
                            onChanged: (String? newValue) {
                              provider.setSelectedBeverages(newValue!);
                            },
                            items: provider.beverages.map((Beverages beverage) {
                              return DropdownMenuItem<String>(
                                value: beverage.nama,
                                child: Text(
                                    '${beverage.nama} - ${Helper.rupiahFormatter(beverage.harga.toDouble())}'),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: _selectedBeveragesQtyController,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: 'Qty',
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      maxLength: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.selectedMethod,
                          isExpanded: true,
                          isDense: true, // Make dropdown less tall
                          onChanged: (val) => provider.setSSelectedMethod(val!),
                          items: provider.methods
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(m),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add Button
                  Material(
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
                        provider.submitBeveragesEntry(
                            _selectedBeveragesQtyController.text);
                        _selectedBeveragesQtyController.clear();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 18),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}
