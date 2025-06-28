import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pos_indorep/screen/transaction/components/rekap_bottom_sheet.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_detail_view.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_list_view.dart';
import 'package:pos_indorep/screen/transaction/components/widget/pagination_widget.dart';
import 'package:provider/provider.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
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
                      IconButton(
                        onPressed: () {
                          provider.getAllTransactions(1);
                        },
                        icon: const Icon(Icons.refresh_rounded),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PaginationWidget(
                          currentPage: provider.currentPageIndex,
                          totalPages: provider.totalPages,
                          onPageChanged: (provider.getAllTransactions)),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            label: const Text('Filter'),
                            icon: Icon(
                              Icons.filter_alt_rounded,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0),
                                          ),
                                        ),
                                        builder: (context) {
                                          return RekapBottomSheet(

                                          );
                                        });
                            },
                            label: const Text('Rekap'),
                            icon: Icon(
                              Icons.assignment_rounded,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TransactionListView(
                    transactions: provider.transactions,
                    onTransactionTap: (transaction) {
                      provider.selectTransaction(transaction);
                    }),
              ]))),
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
