import 'package:flutter/material.dart';
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
    selectedValue = "Pilihan Opsional";
  }

  void _handleSelection(String value) {
    setState(() {
      selectedValue = value;
    });
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
                    labelText: 'Nama Pilihan', labelStyle: GoogleFonts.inter()),
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
            onPressed: () {
              OptionMenuIrep newOption = OptionMenuIrep(
                optionId: 0,
                optionName: _optionNameController.text,
                optionType: selectedValue,
                available: true,
                optionValue: [],
              );
              widget.onOptionAdded(newOption);
              Navigator.of(context).pop();
            },
            child: Text('Simpan')),
      ],
    );
  }
}
