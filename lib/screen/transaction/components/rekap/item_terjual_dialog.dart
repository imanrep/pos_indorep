import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/summary.dart';

class ItemTerjualDialog extends StatelessWidget {
  final SummaryResponse? summaryData;
  const ItemTerjualDialog({super.key, required this.summaryData});

  @override
  Widget build(BuildContext context) {
    // Defensive copy for sorting
    List<ProductSummary> products =
        List<ProductSummary>.from(summaryData!.products!);

    return StatefulBuilder(
      builder: (context, setState) {
        String sortType = 'qty'; // default sort by qty sold
        bool ascending = false;

        void sortProducts(String type, bool asc) {
          setState(() {
            sortType = type;
            ascending = asc;
            if (type == 'qty') {
              products.sort((a, b) => asc
                  ? a.qtySold.compareTo(b.qtySold)
                  : b.qtySold.compareTo(a.qtySold));
            } else if (type == 'name') {
              products.sort((a, b) => asc
                  ? a.productName.compareTo(b.productName)
                  : b.productName.compareTo(a.productName));
            }
          });
        }

        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Item Terjual'),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort_rounded),
                onSelected: (value) {
                  if (value == 'qty_desc') {
                    sortProducts('qty', false);
                  } else if (value == 'qty_asc') {
                    sortProducts('qty', true);
                  } else if (value == 'name_asc') {
                    sortProducts('name', true);
                  } else if (value == 'name_desc') {
                    sortProducts('name', false);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'qty_desc',
                    child: Text('Qty Terbanyak'),
                  ),
                  const PopupMenuItem(
                    value: 'qty_asc',
                    child: Text('Qty Terkecil'),
                  ),
                  const PopupMenuItem(
                    value: 'name_asc',
                    child: Text('Nama A-Z'),
                  ),
                  const PopupMenuItem(
                    value: 'name_desc',
                    child: Text('Nama Z-A'),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: IndorepColor.primary,
                    child: Text(
                      product.productName[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    product.productName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${product.qtySold} Pcs',
                    style: GoogleFonts.inter(fontSize: 14),
                  ),
                  trailing: Text(
                    '${Helper.rupiahFormatter(product.totalIncome.toDouble())}',
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
        );
      },
    );
  }
}
