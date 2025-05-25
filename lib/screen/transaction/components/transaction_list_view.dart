import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:provider/provider.dart';

class TransactionListView extends StatefulWidget {
  final List<TransactionData> transactions;
  final Function(TransactionData) onTransactionTap;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.transactions.length,
        itemBuilder: (context, index) {
          final transaction = widget.transactions[index];

          String total = Helper.rupiahFormatter(transaction.total.toDouble());
          String date = Helper.dateFormatterTwo(transaction.time);
          String time = Helper.timeFormatterTwo(transaction.time);
          String totalCart = transaction.items.length.toString();
          String orderType = transaction.pc.isEmpty ? 'Cafe' : 'Warnet';

          // Determine order status
          String orderStatus;
          if (transaction.status == 'cancelled') {
            orderStatus = 'Dibatalkan';
          } else if (transaction.status == 'pending') {
            orderStatus = 'Pending';
          } else if (transaction.status == 'paid') {
            orderStatus = 'Sukses';
          } else {
            orderStatus = transaction.status; // fallback
          }

          return Container(
            decoration: BoxDecoration(
              color:
                  transaction.orderId == provider.selectedTransaction?.orderId
                      ? Colors.black12
                      : Colors.transparent,
            ),
            child: ListTile(
              onTap: () => widget.onTransactionTap(transaction),
              subtitle: Text(
                '$date - $time | $total (${transaction.paymentMethod.toUpperCase()})',
                style: GoogleFonts.inter(fontWeight: FontWeight.w400),
              ),
              title: Row(
                children: [
                  Text('$orderType - $totalCart Item',
                      style: GoogleFonts.inter(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                ],
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child:
                    Text(orderType[0], style: TextStyle(color: Colors.white)),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize
                    .min, // Ensures the row doesn't take up unnecessary space
                children: [
                  statusChip(orderStatus), // Display status chip
                  const SizedBox(
                      width: 8), // Space between the chip and the arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget statusChip(String status) {
    Color fillColor;
    Color borderColor;

    switch (status) {
      case 'Pending':
        fillColor = Colors.orange.withOpacity(0.1);
        borderColor = Colors.orange;
        break;
      case 'Sukses':
        fillColor = Colors.green.withOpacity(0.1);
        borderColor = Colors.green;
        break;
      default:
        fillColor = Colors.red.withOpacity(0.1);
        borderColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: fillColor,
        border: Border.all(color: borderColor, width: 1.3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: borderColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
