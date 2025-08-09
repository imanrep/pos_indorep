// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:pos_indorep/helper/helper.dart';
// import 'package:pos_indorep/model/summary.dart';

// class DetailDashboardPage extends StatefulWidget {
//   final SummaryResponse? summaryData;
//   const DetailDashboardPage(
//       {super.key, required this.summaryData,});

//   @override
//   State<DetailDashboardPage> createState() => _DetailDashboardPageState();
// }

// class _DetailDashboardPageState extends State<DetailDashboardPage> {
//   late List<OrderSummary> orders =
//       List<OrderSummary>.from(widget.summaryData?.orders ?? []);
//       late List<ProductSummary> products =
//       List<ProductSummary>.from(widget.summaryData?.products ?? []);

//   String sortType = 'income';
//   bool ascending = false;

//   @override
//   void initState() {
//     super.initState();
//     _sortOrders(sortType, ascending);
//   }

//   void _sortOrders(String type, bool asc) {
//     setState(() {
//       sortType = type;
//       ascending = asc;
//       if (type == 'income') {
//         orders.sort((a, b) => asc
//             ? a.totalIncome.compareTo(b.totalIncome)
//             : b.totalIncome.compareTo(a.totalIncome));
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Row(
//             children: [
//               PopupMenuButton<String>(
//                 icon: const Icon(Icons.sort_rounded),
//                 onSelected: (value) {
//                   if (value == 'income_desc') {
//                     _sortOrders('income', false);
//                   } else if (value == 'income_asc') {
//                     _sortOrders('income', true);
//                   }
//                 },
//                 itemBuilder: (context) => [
//                   const PopupMenuItem(
//                     value: 'income_desc',
//                     child: Text('Nominal Tertinggi'),
//                   ),
//                   const PopupMenuItem(
//                     value: 'income_asc',
//                     child: Text('Nominal Terendah'),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             itemCount: orders.length,
//             itemBuilder: (context, index) {
//               if (widget.summaryType == 'totalTransactions' &&
//                   widget.summaryData?.summary.totalOrders == 0) {
//                 return const SizedBox.shrink();
//               } else if (widget.summaryType == 'totalIncome' &&
//                   widget.summaryData?.summary.totalIncome == 0) {
//                 return const SizedBox.shrink();
//               } else if (widget.summaryType == 'totalOrders' &&
//                   widget.summaryData?.summary.totalOrders == 0) {
//                 return const SizedBox.shrink();
//               }
//               final order = orders[index];
//               return ListTile(
//                 leading: CircleAvatar(
//                   backgroundColor: Theme.of(context).colorScheme.primary,
//                   child: Text(
//                     order.products.isNotEmpty
//                         ? order.products[0].productName[0].toUpperCase()
//                         : '?',
//                     style: GoogleFonts.inter(
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//                 title: Text(
//                   '',
//                   style: GoogleFonts.inter(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 subtitle: ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: order.products.length,
//                   itemBuilder: (context, productIndex) {
//                     final product = order.products[productIndex];
//                     return Text(
//                       '${product.productName} (${product.qtySold} Pcs)',
//                       style: GoogleFonts.inter(fontSize: 12),
//                     );
//                   },
//                 ),
//                 trailing: Text(
//                   Helper.rupiahFormatter(order.totalIncome.toDouble()),
//                   style: GoogleFonts.inter(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Theme.of(context).colorScheme.primary,
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
