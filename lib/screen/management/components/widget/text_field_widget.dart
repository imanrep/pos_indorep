import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DropdownFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final List<String> items;
  final String label;

  const DropdownFieldWidget({
    Key? key,
    required this.controller,
    required this.items,
    required this.label,
  }) : super(key: key);

  @override
  _DropdownFieldWidgetState createState() => _DropdownFieldWidgetState();
}

class _DropdownFieldWidgetState extends State<DropdownFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: widget.controller.text.isNotEmpty ? widget.controller.text : null,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: GoogleFonts.inter(),
      ),
      items: widget.items.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category[0].toUpperCase() + category.substring(1)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          widget.controller.text = value!;
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Pilih kategori' : null,
      onSaved: (value) => widget.controller.text = value!,
    );
  }
}
