import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/summary.dart';

class ListTransaksiDialog extends StatelessWidget {
  final SummaryResponse? summaryData;
  const ListTransaksiDialog({super.key, required this.summaryData});

  @override
  Widget build(BuildContext context) {
    // Defensive copy for sorting
    List<OrderSummary> orders = List<OrderSummary>.from(summaryData!.orders!);

    return StatefulBuilder(
      builder: (context, setState) {
        String sortType = 'income'; // default sort by total income
        bool ascending = false;

        void sortOrders(String type, bool asc) {
          setState(() {
            sortType = type;
            ascending = asc;
            if (type == 'income') {
              orders.sort((a, b) => asc
                  ? a.totalIncome.compareTo(b.totalIncome)
                  : b.totalIncome.compareTo(a.totalIncome));
            }
          });
        }

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('List Transaksi'),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                onSelected: (value) {
                  if (value == 'income_desc') {
                    sortOrders('income', false);
                  } else if (value == 'income_asc') {
                    sortOrders('income', true);
                  } else if (value == 'order_asc') {
                    sortOrders('order', true);
                  } else if (value == 'order_desc') {
                    sortOrders('order', false);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'income_desc',
                    child: Text('Nominal Tertinggi'),
                  ),
                  const PopupMenuItem(
                    value: 'income_asc',
                    child: Text('Nominal Terendah'),
                  ),
                ],
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: IndorepColor.primary,
                          child: Text(
                            order.products.isNotEmpty
                                ? order.products[0].productName[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(
                          'Order #${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.products.length,
                          itemBuilder: (context, productIndex) {
                            final product = order.products[productIndex];
                            return Text(
                              '${product.productName} (${product.qtySold} Pcs)',
                              style: GoogleFonts.inter(fontSize: 12),
                            );
                          },
                        ),
                        trailing: Text(
                          Helper.rupiahFormatter(order.totalIncome.toDouble()),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
