import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
import 'package:provider/provider.dart';

class BeveragesTransactionList extends StatelessWidget {
  const BeveragesTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child:
          Consumer<WebTransaksiProvider>(builder: (context, provider, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: IndorepColor.primary, width: 1.5),
          ),
          elevation: 2,
          child: Column(
            children: [
              const SizedBox(height: 12),
              DateBar(
                selectedDate: provider.selectedBeveragesDate,
                onDateChanged: provider.onBeveragesDateChanged,
              ),
              provider.isLoadingBeverages
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : provider.currentBeveragesEntries.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text('Tidak ada Penjualan',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: Colors.grey,
                                )),
                          ),
                        )
                      : Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  provider.currentBeveragesEntries.length,
                              itemBuilder: (context, index) {
                                final e =
                                    provider.currentBeveragesEntries[index];
                                final rawTimestamp = e['timestamp'];
                                final dt = rawTimestamp is Timestamp
                                    ? rawTimestamp.toDate()
                                    : DateTime.now();
                                final formattedDate =
                                    DateFormat('HH:mm', 'id_ID').format(dt);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: Icon(Icons.receipt_long_rounded),
                                    title: Text(
                                        '${e['qty']}x - ${e['beverages.nama']}'),
                                    subtitle: Text(
                                        '$formattedDate | ${Helper.rupiahFormatter(e['grandTotal'])} | ${e['metode']} | OP: ${e['operator']}'),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total Transaksi: ${provider.currentBeveragesEntries.length}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Pendapatan: ${Helper.rupiahFormatter(provider.currentBeveragesEntries.fold(0, (sum, e) => sum + e['grandTotal']))}',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
            ],
          ),
        );
      }),
    );
  }
}
