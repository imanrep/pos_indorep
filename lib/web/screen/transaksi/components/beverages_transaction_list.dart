// import 'package:fluent_ui/fluent_ui.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:pos_indorep/helper/helper.dart';
// import 'package:pos_indorep/provider/web/web_transaksi_provider.dart';
// import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
// import 'package:provider/provider.dart';

// class BeveragesTransactionList extends StatelessWidget {
//   const BeveragesTransactionList({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Consumer<WebTransaksiProvider>(
//         builder: (context, provider, child) {
//           final totalPendapatan = provider.currentBeveragesEntries
//               .fold(0, (sum, e) => sum + e.grandTotal);
//           final totalPendapatanCash = provider.currentBeveragesEntries.fold(
//               0, (sum, e) => sum + (e.metode == 'Cash' ? e.grandTotal : 0));
//           final totalPendapatanQris = provider.currentBeveragesEntries.fold(
//               0, (sum, e) => sum + (e.metode == 'QRIS' ? e.grandTotal : 0));

//           return Card(
//             borderRadius: BorderRadius.circular(12),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Text(
//                     'Daftar Transaksi Minuman',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 20,
//                     ),
//                   ),
//                 ),
//                 DateBar(
//                   selectedDate: provider.selectedBeveragesDate,
//                   onDateChanged: provider.onBeveragesDateChanged,
//                 ),
//                 const SizedBox(height: 12),
//                 provider.isLoadingBeverages
//                     ? const Padding(
//                         padding: EdgeInsets.all(16.0),
//                         child: Center(child: ProgressRing()),
//                       )
//                     : provider.currentBeveragesEntries.isEmpty
//                         ? Padding(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Center(
//                               child: Text(
//                                 'Tidak ada Penjualan',
//                                 style: GoogleFonts.inter(
//                                   fontSize: 16,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Column(
//                             children: [
//                               ListView.separated(
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 itemCount:
//                                     provider.currentBeveragesEntries.length,
//                                 separatorBuilder: (_, __) =>
//                                     const Divider(size: 1),
//                                 itemBuilder: (context, index) {
//                                   final e =
//                                       provider.currentBeveragesEntries[index];
//                                   final rawTimestamp = e.timestamp;
//                                   final dt = rawTimestamp is DateTime
//                                       ? rawTimestamp
//                                       : (rawTimestamp as dynamic)?.toDate() ??
//                                           DateTime.now();
//                                   final formattedDate =
//                                       DateFormat('HH:mm', 'id_ID').format(dt);
//                                   return ListTile(
//                                     leading: const Icon(
//                                         FluentIcons.receipt_processing),
//                                     title: Text(
//                                       '${e.qty}x - ${e.beverages.nama}',
//                                       style: GoogleFonts.inter(),
//                                     ),
//                                     subtitle: Text(
//                                       '$formattedDate | ${Helper.rupiahFormatter(e.grandTotal.toDouble())} | ${e.metode} | OP: ${e.operator}',
//                                       style: GoogleFonts.inter(fontSize: 13),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               const SizedBox(height: 16),
//                               Align(
//                                 alignment: Alignment.centerRight,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(right: 24.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         'Total Transaksi: ${provider.currentBeveragesEntries.length}',
//                                         style: GoogleFonts.inter(
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Cash Masuk: ${Helper.rupiahFormatter(totalPendapatanCash.toDouble())}',
//                                         style: GoogleFonts.inter(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'QRIS Masuk: ${Helper.rupiahFormatter(totalPendapatanQris.toDouble())}',
//                                         style: GoogleFonts.inter(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Text(
//                                         'Total Pendapatan: ${Helper.rupiahFormatter(totalPendapatan.toDouble())}',
//                                         style: GoogleFonts.inter(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 16),
//                             ],
//                           ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
