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
}
