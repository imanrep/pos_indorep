// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pos_indorep/helper/helper.dart';
// import 'package:pos_indorep/model/model.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ReceiptPrintView extends StatefulWidget {
//   final QrisOrderResponse response;
//   const ReceiptPrintView({super.key, required this.response});

//   @override
//   State<ReceiptPrintView> createState() => _ReceiptPrintViewState();
// }

// class _ReceiptPrintViewState extends State<ReceiptPrintView> {
//   ReceiptController? controller;
//   double? progress;
//   bool isPrinting = false;

//   Future<void> _startPrint() async {
//     final address = "";

//     if (address.isEmpty) {
//       return;
//     }

//     controller!.print(
//       address: address,
//       addFeeds: 5,
//       keepConnected: true,
//       onProgress: (total, sent) {},
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     String orderType = widget.response.qris.isEmpty ? 'Cash' : 'QRIS';
//     return Receipt(
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Column(
//           children: [
//             Text('INDOREP GAMING & CAFFE',
//                 style: GoogleFonts.robotoMono(
//                     fontSize: 28, fontWeight: FontWeight.w800)),
//             const SizedBox(height: 4),
//             Text('Jl. Margonda No. 386, Beji, Kota Depok',
//                 style: GoogleFonts.robotoMono(fontSize: 18)),
//             const SizedBox(height: 24),
//             Text(
//                 '----------------------------------------------------------------',
//                 style: GoogleFonts.robotoMono(fontSize: 18)),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text("SUCCESS", style: GoogleFonts.robotoMono(fontSize: 18)),
//                   Text(
//                       '${Helper.dateFormatterTwo(DateTime.now().toIso8601String())} - ${Helper.timeFormatterTwo(DateTime.now().toIso8601String())}',
//                       style: GoogleFonts.robotoMono(fontSize: 18)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Via: ',
//                     style: GoogleFonts.robotoMono(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                   Text(
//                     orderType,
//                     style: GoogleFonts.robotoMono(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Text(
//                 '----------------------------------------------------------------',
//                 style: GoogleFonts.robotoMono(fontSize: 18)),
//             const SizedBox(height: 12),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Pesanan:',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 'Total: ${Helper.rupiahFormatter(widget.response.total.toDouble())}',
//                 style: GoogleFonts.robotoMono(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               'Info, saran, dan masukan',
//               style: GoogleFonts.robotoMono(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             Text(
//               'business@indorep.com',
//               style: GoogleFonts.robotoMono(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             const SizedBox(height: 24),
//             widget.response.qris.isNotEmpty
//                 ? Center(
//                     child: QrImageView(
//                       data: widget.response.qris,
//                       version: QrVersions.auto,
//                       size: 120.0,
//                     ),
//                   )
//                 : const SizedBox.shrink(),
//             const SizedBox(height: 24),
//             Text(
//               'Terima Kasih!',
//               style: GoogleFonts.robotoMono(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             Opacity(
//               opacity: 0,
//               child: SizedBox(
//                 height: 150,
//               ),
//             ),
//           ],
//         );
//       },
//       onInitialized: (ctrl) => setState(() => controller = ctrl),
//     );
//   }
// }
