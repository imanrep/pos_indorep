import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
import 'package:provider/provider.dart';

class WarnetTransactionList extends StatelessWidget {
  const WarnetTransactionList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                selectedDate: provider.selectedWarnetDate,
                onDateChanged: (date) {
                  provider.onWarnetDateChanged(date);
                },
              ),
              provider.isLoadingEntries
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CupertinoActivityIndicator()),
                    )
                  : provider.currentWarnetEntries.isEmpty
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
                              itemCount: provider.currentWarnetEntries.length,
                              itemBuilder: (context, index) {
                                final e = provider.currentWarnetEntries[index];
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
                                        '${e['username']} - ${e['paket.nama']}'),
                                    subtitle: Text(
                                        '$formattedDate | ${Helper.rupiahFormatter(e['paket.harga'])} | ${e['metode']} | OP: ${e['operator']}'),
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
                                      'Total Transaksi: ${provider.currentWarnetEntries.length}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total Pendapatan: ${Helper.rupiahFormatter(provider.currentWarnetEntries.fold(0, (sum, e) => sum + e['paket.harga']))}',
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
