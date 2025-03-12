import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Helper {
  static String rupiahFormatter(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }

  static String dateFormatter(int date) {
    final formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(DateTime.fromMillisecondsSinceEpoch(date));
  }

  static String timeFormatter(int date) {
    final formatter = DateFormat('HH:mm');
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
