import 'package:flutter/material.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_detail_view.dart';
import 'package:pos_indorep/screen/transaction/components/transaction_list_view.dart';
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
    // Provider.of<TransactionProvider>(context, listen: false)
    //     .getAllTransactions();
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
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Transaksi', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          height: 46,
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: SearchAnchor(builder: (BuildContext context,
                              SearchController controller) {
                            return SearchBar(
                              hintText: 'Cari transaksi...',
                              controller: controller,
                              padding: const WidgetStatePropertyAll<EdgeInsets>(
                                  EdgeInsets.symmetric(horizontal: 16.0)),
                              onTap: () {
                                controller.openView();
                              },
                              onChanged: (_) {
                                controller.openView();
                              },
                              leading: const Icon(Icons.search),
                            );
                          }, suggestionsBuilder: (BuildContext context,
                              SearchController controller) {
                            return List<ListTile>.generate(5, (int index) {
                              final String item = 'item $index';
                              return ListTile(
                                title: Text(item),
                                onTap: () {
                                  setState(() {
                                    controller.closeView(item);
                                  });
                                },
                              );
                            });
                          }),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {},
                            label: const Text('Urutkan'),
                            icon: Icon(
                              Icons.sort_rounded,
                              size: 28,
                            ),
                          ),
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
                  ],
                ),
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
