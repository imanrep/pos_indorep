import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConfirmationDialog extends StatelessWidget {
  final Function(bool) onConfirmation;
  const ConfirmationDialog({required this.onConfirmation, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Abaikan Perubahan',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
      content:
          SingleChildScrollView(child: Text('Abaikan perubahan pada menu?')),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirmation(true);
            Navigator.of(context).pop();
          },
          child: const Text('Abaikan'),
        ),
      ],
    );
  }
}
