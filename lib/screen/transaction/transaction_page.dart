import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
// import 'package:pos_indorep/screen/transaction/components/rekap_bottom_sheet.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_detail_view.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_list_view.dart';
import 'package:pos_indorep/screen/transaction/components/widget/pagination_widget.dart';
import 'package:pos_indorep/screen/transaction/components/widget/refresh_spin_button.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

enum FilterType { all, cafe, warnet }

class _TransactionPageState extends State<TransactionPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // FilterType _selectedFilter = FilterType.all;
  @override
  void initState() {
    super.initState();
    _fetchAllTransaction();
  }

  Future<void> _fetchAllTransaction() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.getAllTransactions(provider.currentPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(builder: (context, provider, child) {
      return Scaffold(
          body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 4,
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _fetchAllTransaction,
                child: SingleChildScrollView(
                    child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Text('Transaksi',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 28.0)),
                        const Spacer(),
                        RefreshSpinButton(
                          onPressed: () async {
                            _refreshIndicatorKey.currentState?.show();
                            provider.getAllTransactions(1);
                          },
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: PaginationWidget(
                            currentPage: provider.currentPageIndex,
                            totalPages: provider.totalPages,
                            onPageChanged: (provider.getAllTransactions)),
                      ),
                      const SizedBox(height: 8),
                      // Expanded(
                      //   flex: 1,
                      //   child: Row(
                      //     children: [
                      //       TextButton.icon(
                      //         onPressed: () {
                      //           showDialog(
                      //             context: context,
                      //             builder: (context) => AlertDialog(
                      //               title: const Text('Filter Transaksi'),
                      //               content: Consumer<TransactionProvider>(
                      //                 builder: (context, provider, _) => Column(
                      //                   mainAxisSize: MainAxisSize.min,
                      //                   children: [
                      //                     ListTile(
                      //                       title: const Text('Sumber'),
                      //                       subtitle: Row(
                      //                         children: [
                      //                           Radio<FilterType>(
                      //                             value: FilterType.all,
                      //                             groupValue:
                      //                                 provider.filterSource,
                      //                             onChanged: (value) {
                      //                               provider
                      //                                   .filterTransactionsByType(
                      //                                       value!);
                      //                               Navigator.pop(context);
                      //                             },
                      //                           ),
                      //                           const Text('Semua'),
                      //                           Radio<FilterType>(
                      //                             value: FilterType.cafe,
                      //                             groupValue:
                      //                                 provider.filterSource,
                      //                             onChanged: (value) {
                      //                               provider
                      //                                   .filterTransactionsByType(
                      //                                       value!);
                      //                               Navigator.pop(context);
                      //                             },
                      //                           ),
                      //                           const Text('Cafe'),
                      //                           Radio<FilterType>(
                      //                             value: FilterType.warnet,
                      //                             groupValue:
                      //                                 provider.filterSource,
                      //                             onChanged: (value) {
                      //                               provider
                      //                                   .filterTransactionsByType(
                      //                                       value!);
                      //                               Navigator.pop(context);
                      //                             },
                      //                           ),
                      //                           const Text('Warnet'),
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ),
                      //               actions: [
                      //                 TextButton(
                      //                   onPressed: () => Navigator.pop(context),
                      //                   child: const Text('Tutup'),
                      //                 ),
                      //               ],
                      //             ),
                      //           );
                      //         },
                      //         label: Text('Filter',
                      //             style: GoogleFonts.inter(
                      //                 fontWeight: FontWeight.w600)),
                      //         icon: Icon(
                      //           Icons.filter_alt_rounded,
                      //           size: 28,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TransactionListView(
                    transactions: provider.filteredTransactions,
                    onTransactionTap: (transaction) {
                      provider.selectTransaction(transaction);
                      provider.markOrderIdAsSeen(transaction.orderId);
                    },
                  ),
                ])),
              )),
          const VerticalDivider(thickness: 0.5, width: 1),
          Expanded(
              flex: 2,
              child: Consumer<TransactionProvider>(
                  builder: (context, provider, child) {
                if (provider.selectedTransaction == null) {
                  return Container();
                }
                return TransactionDetailView(
                    transaction: provider.selectedTransaction!);
              })),
        ],
      ));
    });
  }
}
