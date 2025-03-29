import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/model/model.dart';

class EditOptionDialog extends StatefulWidget {
  final OptionMenuIrep option;
  final Function(OptionMenuIrep) onOptionChanged;

  const EditOptionDialog(
      {required this.onOptionChanged, required this.option, super.key});

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
            text: optionValue.optionValuePrice.toString()))
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
              ),
              onChanged: (value) {
                setState(() {
                  localOption = localOption.copyWith(optionName: value);
                });
              },
            ),
            const SizedBox(height: 28),
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
                      decoration:
                          InputDecoration(labelText: 'Opsi ${index + 1}'),
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
                    child: TextField(
                      controller: _optionValuePriceControllers[index],
                      decoration:
                          InputDecoration(labelText: 'Harga ${index + 1}'),
                      onChanged: (value) {
                        setState(() {
                          localOption.optionValue[index] = localOption
                              .optionValue[index]
                              .copyWith(optionValueName: value);
                        });
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
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
            OptionMenuIrep newOption = OptionMenuIrep(
              optionId: 0,
              optionName: widget.option.optionName,
              optionType: widget.option.optionType,
              available: widget.option.available,
              optionValue: [
                for (var i = 0; i < localOption.optionValue.length; i++)
                  OptionValue(
                    optionValueName: _optionValueNameControllers[i].text,
                    optionValuePrice:
                        int.parse(_optionValuePriceControllers[i].text),
                    optionValueId: 0,
                    isSelected: false,
                  ),
              ],
            );
            widget.onOptionChanged(newOption);
            Navigator.of(context).pop();
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
