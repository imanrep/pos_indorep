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
}
