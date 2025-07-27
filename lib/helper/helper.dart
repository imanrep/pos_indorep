import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class Helper {
  static String rupiahFormatter(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String rupiahFormatterTwo(int price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String dateFormatterTwo(String dateTimeString) {
    DateTime dt = DateTime.parse(dateTimeString);
    // final dayOfWeek = DateFormat('EEEE', 'id_ID').format(dt);
    final formattedDate = DateFormat('dd-MM-yyyy', 'id_ID').format(dt);
    return '$formattedDate';
  }

  static String timeFormatterTwo(String dateTimeString) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(DateTime.parse(dateTimeString));
  }

  static String dateFormatter(int date) {
    final formatter = DateFormat('d MMMM yyyy', 'id_ID');
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  static String timeFormatter(int date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  // New method to format date like 'Jumat, 2 Mei 2025'
  static String formattedDateWithDay(int date) {
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(date));
  }
}

class RupiahFormatter extends TextInputFormatter {
  final NumberFormat _formatter =
      NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double value =
        double.tryParse(newValue.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
    String newText = _formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class IndorepColor {
  static const Color primary = Color(0xFF8963D5); // Hex #8963D5
  static const Color secondary = Color(0xFF4A2FBD); // Example secondary color
  static const Color background = Color(0xFF121212); // Dark mode background
  static const Color text = Color(0xFFFFFFFF); // White text
}

class PrettyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const PrettyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.icon = Icons.edit,
    this.isPassword = false,
  }) : super(key: key);

  @override
  _PrettyTextFieldState createState() => _PrettyTextFieldState();
}

class _PrettyTextFieldState extends State<PrettyTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(widget.icon, color: Colors.blueGrey.shade700),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.blueGrey.shade700,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : (widget.controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {});
                    },
                  )
                : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
