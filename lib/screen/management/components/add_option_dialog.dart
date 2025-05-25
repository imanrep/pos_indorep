import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/model/model.dart';

class AddOptionDialog extends StatefulWidget {
  final Function(OptionMenuIrep) onOptionAdded;

  const AddOptionDialog({required this.onOptionAdded, super.key});

  @override
  State<AddOptionDialog> createState() => _AddOptionDialogState();
}

class _AddOptionDialogState extends State<AddOptionDialog> {
  late TextEditingController _optionNameController;
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    _optionNameController = TextEditingController();
    selectedValue = "";

    // Add a listener to the text controller to rebuild the widget on text changes
    _optionNameController.addListener(() {
      setState(() {}); // Rebuild the widget when the text changes
    });
  }

  void _handleSelection(String value) {
    setState(() {
      selectedValue = value;
    });
  }

  @override
  void dispose() {
    _optionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tambah Pilihan',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Column(
            children: [
              TextField(
                controller: _optionNameController,
                decoration: InputDecoration(
                    labelText: 'Nama Pilihan',
                    labelStyle: GoogleFonts.inter(),
                    counterText: ""),
                maxLength: 20,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/\s]')),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Tipe Pilihan',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RadioListTile<String>(
                title: Text("Pilihan Opsional", style: GoogleFonts.inter()),
                value: "Checkbox",
                groupValue: selectedValue,
                onChanged: (value) => _handleSelection(value!),
              ),
              RadioListTile<String>(
                title: Text("Pilihan Wajib", style: GoogleFonts.inter()),
                value: "Radio",
                groupValue: selectedValue,
                onChanged: (value) => _handleSelection(value!),
              ),
            ],
          )
        ]),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed:
              _optionNameController.text.isNotEmpty && selectedValue.isNotEmpty
                  ? () {
                      OptionMenuIrep newOption = OptionMenuIrep(
                        optionId: 0,
                        optionName: _optionNameController.text,
                        optionType: selectedValue,
                        available: true,
                        optionValue: [],
                      );
                      widget.onOptionAdded(newOption);
                      Navigator.of(context).pop();
                    }
                  : null, // Disable the button if validation fails
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
