import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/date_symbols.dart';
// import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/dashboard_provider.dart';
import 'package:pos_indorep/screen/dashboard/components/dashboard_card.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
// import 'package:pos_indorep/screen/transaction/components/widget/date_range_bar.dart';
// import 'package:pos_indorep/screen/dashboard/components/line_chart.dart';
// import 'package:pos_indorep/screen/dashboard/page/detail_dashboard_page.dart';
// import 'package:pos_indorep/screen/transaction/components/rekap/item_terjual_dialog.dart';
// import 'package:pos_indorep/screen/transaction/components/rekap/list_transaksi_dialog.dart';
// import 'package:pos_indorep/screen/transaction/components/widget/summary_box_widget.dart';
// import 'package:pos_indorep/services/irepbe_services.dart';
import 'package:provider/provider.dart';

class TabletDashboardPage extends StatefulWidget {
  const TabletDashboardPage({super.key});

  @override
  State<TabletDashboardPage> createState() => _TabletDashboardPageState();
}

class _TabletDashboardPageState extends State<TabletDashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  // List<DropdownMenuItem<String>> _summaryDropdown() {
  //   return [
  //     DropdownMenuItem(
  //       value: 'all',
  //       child: Text('Keseluruhan'),
  //     ),
  //     DropdownMenuItem(
  //       value: 'monthly',
  //       child: Text('Bulanan'),
  //     ),
  //     DropdownMenuItem(
  //       value: 'range',
  //       child: Text('Filter Tanggal'),
  //     ),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, provider, child) {
      return Scaffold(
          body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('Dashboard',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 28.0)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DateBar(
                      selectedDate: provider.selectedDate,
                      isLoading: provider.isLoading,
                      onDateChanged: (newDate) async {
                        await provider.setSelectedDateAndFetchSummary(newDate);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (provider.dailySummary == null)
                      const Center(child: CupertinoActivityIndicator())
                    else
                      LayoutBuilder(builder: (context, constraints) {
                        return provider.isLoading
                            ? GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1,
                                children: [
                                    const SizedBox(),
                                    CupertinoActivityIndicator(),
                                    const SizedBox(),
                                  ])
                            : GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1,
                                children: [
                                  DashboardCard(
                                    title: 'Transaksi',
                                    subtitle:
                                        '${provider.dailySummary!.summary.totalOrders}',
                                    performance:
                                        provider.totalTransactionsPerformance,
                                    icon: Icons.receipt_long_rounded,
                                    isWidthExpanded: false,
                                    onTap: () {
                                      provider.setActiveOrderSummary(
                                          provider.dailySummary);
                                      provider.setActiveSummaryType(
                                          "totalTransactions");
                                    },
                                  ),
                                  DashboardCard(
                                    title: 'Item Terjual',
                                    subtitle:
                                        '${provider.dailySummary!.summary.totalItems}',
                                    performance: provider.totalItemsPerformance,
                                    icon: Icons.shopping_cart_rounded,
                                    isWidthExpanded: false,
                                    onTap: () {
                                      provider.setActiveOrderSummary(
                                          provider.dailySummary);
                                      provider
                                          .setActiveSummaryType("totalItems");
                                    },
                                  ),
                                  DashboardCard(
                                    title: 'Omzet',
                                    subtitle: Helper.rupiahFormatter(provider
                                        .dailySummary!.summary.totalIncome
                                        .toDouble()),
                                    performance: provider.totalOmzetPerformance,
                                    icon: Icons.payments_rounded,
                                    isWidthExpanded: false,
                                  ),
                                ],
                              );
                      }),
                    // const Divider(),
                    // Row(
                    //   children: [
                    //     DropdownButton(
                    //       underline: SizedBox(),
                    //       items: _summaryDropdown(),
                    //       style: GoogleFonts.inter(
                    //         fontWeight: FontWeight.w600,
                    //         fontSize: 18,
                    //         color: Theme.of(context).colorScheme.onSurface,
                    //       ),
                    //       onChanged: (value) {
                    //         if (value != null) {
                    //           var irepBE = IrepBE();
                    //           if (value == 'all') {
                    //             irepBE
                    //                 .getSummary('all', null, null)
                    //                 .then((value) {
                    //               provider.setFilteredSummary(value);
                    //             });
                    //           } else if (value == 'daily') {
                    //             irepBE
                    //                 .getSummary('daily', null, null)
                    //                 .then((value) {
                    //               provider.setFilteredSummary(value);
                    //             });
                    //           } else if (value == 'monthly') {
                    //             irepBE
                    //                 .getSummary('monthly', null, null)
                    //                 .then((value) {
                    //               provider.setFilteredSummary(value);
                    //             });
                    //           } else if (value == 'yearly') {
                    //             irepBE
                    //                 .getSummary('yearly', null, null)
                    //                 .then((value) {
                    //               provider.setFilteredSummary(value);
                    //             });
                    //           }
                    //           setState(() {
                    //             provider
                    //                 .setSelectedSummaryType(value.toString());
                    //             provider.setIsRangeDatePicker(value == 'range');
                    //           });
                    //         }
                    //       },
                    //       value: provider.selectedSummaryType,
                    //       hint: Text('Pilih Rekap'),
                    //     ),
                    //     const Spacer(),
                    //     provider.isRangeDatePicker
                    //         ? DateRangeBar(
                    //             selectedRange: provider.selectedRange,
                    //             onRangeChanged: (newRange) {
                    //               setState(() {
                    //                 provider.setSelectedRange(newRange);
                    //               });

                    //               var irepBE = IrepBE();
                    //               irepBE
                    //                   .getSummary(
                    //                 null,
                    //                 DateFormat('dd-MM-yyyy')
                    //                     .format(newRange.start),
                    //                 DateFormat('dd-MM-yyyy')
                    //                     .format(newRange.end),
                    //               )
                    //                   .then((value) {
                    //                 provider.setFilteredSummary(value);
                    //               });
                    //             },
                    //           )
                    //         : SizedBox(),
                    //   ],
                    // ),
                    // const SizedBox(height: 16),
                    // // const SizedBox(height: 8),
                    // // LineChartSample1(),
                    // if (provider.dailySummary == null)
                    //   const Center(child: CircularProgressIndicator())
                    // else
                    //   LayoutBuilder(builder: (context, constraints) {
                    //     return GridView.count(
                    //       crossAxisCount: 3,
                    //       crossAxisSpacing: 0,
                    //       mainAxisSpacing: 0,
                    //       shrinkWrap: true,
                    //       physics: const NeverScrollableScrollPhysics(),
                    //       childAspectRatio: 1,
                    //       children: [
                    //         DashboardCard(
                    //           title: 'Transaksi',
                    //           subtitle:
                    //               '${provider.filteredSummary!.summary.totalOrders}',
                    //           performance:
                    //               provider.totalTransactionsPerformance,
                    //           icon: Icons.receipt_long_rounded,
                    //           isWidthExpanded: false,
                    //           onTap: () {
                    //             provider.setActiveOrderSummary(
                    //                 provider.filteredSummary);
                    //             provider
                    //                 .setActiveSummaryType("totalTransactions");
                    //           },
                    //         ),
                    //         DashboardCard(
                    //           title: 'Item Terjual',
                    //           subtitle:
                    //               '${provider.filteredSummary!.summary.totalItems}',
                    //           performance: provider.totalItemsPerformance,
                    //           icon: Icons.shopping_cart_rounded,
                    //           isWidthExpanded: false,
                    //           onTap: () {
                    //             provider.setActiveOrderSummary(
                    //                 provider.filteredSummary);
                    //             provider.setActiveSummaryType("totalItems");
                    //           },
                    //         ),
                    //         DashboardCard(
                    //           title: 'Omzet',
                    //           performance: provider.totalOmzetPerformance,
                    //           subtitle: Helper.rupiahFormatter(provider
                    //               .filteredSummary!.summary.totalIncome
                    //               .toDouble()),
                    //           icon: Icons.payments_rounded,
                    //           isWidthExpanded: false,
                    //         ),
                    //       ],
                    //     );
                    //   }),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 0.5, thickness: 1),
          Expanded(
              flex: 1,
              child: Consumer<DashboardProvider>(
                  builder: (context, provider, child) {
                if (provider.activeOrderSummary == null) {
                  return Center(
                    child: Text(
                      'Tidak ada data transaksi',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox(height: 16);
                }
              }))
        ],
      ));
    });
  }
}
