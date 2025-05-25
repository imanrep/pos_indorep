import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';

class EditOptionDialog extends StatefulWidget {
  final OptionMenuIrep option;
  final Function(OptionMenuIrep) onOptionChanged;
  final Function(int) onOptionValueDeleted;

  const EditOptionDialog(
      {required this.onOptionChanged,
      required this.option,
      required this.onOptionValueDeleted,
      super.key});

  @override
  State<EditOptionDialog> createState() => _EditOptionDialogState();
}

class _EditOptionDialogState extends State<EditOptionDialog> {
  late List<TextEditingController> _optionValueNameControllers;
  late List<TextEditingController> _optionValuePriceControllers;
  late TextEditingController _judulController;
  late OptionMenuIrep localOption;

  @override
  void initState() {
    super.initState();
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    // Create a local mutable copy of the option
    localOption = OptionMenuIrep(
      optionId: widget.option.optionId,
      optionName: widget.option.optionName,
      optionType: widget.option.optionType,
      available: widget.option.available,
      optionValue: widget.option.optionValue
          .map((optVal) => OptionValue(
                optionValueName: optVal.optionValueName,
                optionValueId: optVal.optionValueId,
                optionValuePrice: optVal.optionValuePrice,
                isSelected: optVal.isSelected,
              ))
          .toList(),
    );

    // Create controllers for each option value
    _optionValueNameControllers = localOption.optionValue
        .map((optionValue) =>
            TextEditingController(text: optionValue.optionValueName))
        .toList();

    _optionValuePriceControllers = localOption.optionValue
        .map((optionValue) => TextEditingController(
            text: formatter.format(optionValue.optionValuePrice)))
        .toList();

    _judulController = TextEditingController(text: localOption.optionName);
  }

  @override
  void dispose() {
    for (var controller in _optionValueNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Pilihan',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                  label: Text('Nama Pilihan', style: GoogleFonts.inter()),
                  counterText: ""),
              maxLength: 20,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/\s]')),
              ],
              onChanged: (value) {
                setState(() {
                  localOption = localOption.copyWith(optionName: value);
                });
              },
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Text(
                    'Pilihan (${localOption.optionValue.length})',
                    style: GoogleFonts.inter(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        localOption.optionValue.add(OptionValue(
                          optionValueName: '',
                          optionValuePrice: 0,
                          optionValueId: 0,
                          isSelected: false,
                        ));
                        _optionValueNameControllers
                            .add(TextEditingController());
                        _optionValuePriceControllers
                            .add(TextEditingController());
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...localOption.optionValue.asMap().entries.map((entry) {
              int index = entry.key;
              return Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      controller: _optionValueNameControllers[index],
                      decoration: InputDecoration(
                          labelText: 'Opsi ${index + 1}', counterText: ""),
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9/\s]')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          localOption.optionValue[index] = localOption
                              .optionValue[index]
                              .copyWith(optionValueName: value);
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _optionValuePriceControllers[index],
                      decoration: InputDecoration(
                          labelText: 'Harga ${index + 1}', counterText: ""),
                      maxLength: 8,
                      keyboardType: TextInputType.number,
                      inputFormatters: [RupiahFormatter()],
                      onSaved: (value) {
                        double rawValue = double.tryParse(
                                value!.replaceAll(RegExp(r'[^0-9]'), '')) ??
                            0.0;
                        _optionValuePriceControllers[index].text =
                            rawValue.toString();
                      },
                      onChanged: (value) {
                        setState(() {
                          // Remove non-numeric characters (e.g., Rp and .) before parsing
                          String numericValue =
                              value.replaceAll(RegExp(r'[^0-9]'), '');
                          localOption.optionValue[index] =
                              localOption.optionValue[index].copyWith(
                                  optionValuePrice:
                                      int.tryParse(numericValue) ?? 0);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        widget.onOptionValueDeleted(
                            localOption.optionValue[index].optionValueId);
                        setState(() {
                          localOption.optionValue.removeAt(index);
                          _optionValueNameControllers.removeAt(index);
                          _optionValuePriceControllers.removeAt(index);
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            OptionMenuIrep newOption = localOption;
            widget.onOptionChanged(newOption);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
