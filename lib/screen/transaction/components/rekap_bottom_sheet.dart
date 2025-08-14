import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/summary.dart';
import 'package:pos_indorep/screen/transaction/components/rekap/item_terjual_dialog.dart';
import 'package:pos_indorep/screen/transaction/components/rekap/list_transaksi_dialog.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_range_bar.dart';
import 'package:pos_indorep/screen/transaction/components/widget/summary_box_widget.dart';
import 'package:pos_indorep/services/cafe_backend_services.dart';

class RekapBottomSheet extends StatefulWidget {
  const RekapBottomSheet({
    super.key,
  });

  @override
  State<RekapBottomSheet> createState() => _RekapBottomSheetState();
}

class _RekapBottomSheetState extends State<RekapBottomSheet> {
  SummaryResponse? filteredSummary;
  SummaryResponse? dailySummary;
  DateTime selectedDate = DateTime.now();
  bool isRangeDatePicker = false;
  String selectedSummaryType = 'all';
  DateTimeRange selectedRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _initSummaryData();
  }

  Future<void> _initSummaryData() async {
    var irepBE = CafeBackendServices();

    SummaryResponse allSummaryResponse =
        await irepBE.getSummary('all', null, null);
    SummaryResponse? filteredSummaryResponse =
        await irepBE.getSummary('daily', null, null);

    setState(() {
      filteredSummary = allSummaryResponse;
      dailySummary = filteredSummaryResponse;
    });
  }

  List<DropdownMenuItem<String>> _summaryDropdown() {
    return [
      DropdownMenuItem(
        value: 'all',
        child: Text('Keseluruhan'),
      ),
      DropdownMenuItem(
        value: 'monthly',
        child: Text('Bulanan'),
      ),
      DropdownMenuItem(
        value: 'range',
        child: Text('Filter Tanggal'),
      ),
    ];
  }
  // Widget _filteredSummaryWidget(){

  //   return Text('');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Rekap Transaksi',
            style:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Harian',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              DateBar(
                selectedDate: selectedDate,
                onDateChanged: (newDate) {
                  selectedDate = newDate;
                  String formattedDate =
                      DateFormat('dd-MM-yyyy').format(newDate);
                  var irepBE = CafeBackendServices();
                  irepBE
                      .getSummary(null, formattedDate, formattedDate)
                      .then((value) {
                    setState(() {
                      dailySummary = value;
                      selectedDate = newDate;
                    });
                  });
                },
              ),
              const SizedBox(height: 8),
              if (dailySummary == null)
                const Center(child: CircularProgressIndicator())
              else
                LayoutBuilder(builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      SummaryBoxWidget(
                        title: 'Transaksi',
                        subtitle: '${dailySummary!.summary.totalOrders}',
                        icon: Icons.receipt_long_rounded,
                        isWidthExpanded: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ListTransaksiDialog(
                              summaryData: dailySummary!,
                            ),
                          );
                        },
                      ),
                      SummaryBoxWidget(
                        title: 'Item Terjual',
                        subtitle: '${dailySummary!.summary.totalItems}',
                        icon: Icons.shopping_cart_rounded,
                        isWidthExpanded: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ItemTerjualDialog(
                              summaryData: dailySummary!,
                            ),
                          );
                        },
                      ),
                      SummaryBoxWidget(
                        title: 'Omzet',
                        subtitle: Helper.rupiahFormatter(
                            dailySummary!.summary.totalIncome.toDouble()),
                        icon: Icons.payments_rounded,
                        isWidthExpanded: false,
                      ),
                    ],
                  );
                }),
              const Divider(),
              Row(
                children: [
                  DropdownButton(
                    underline: SizedBox(),
                    items: _summaryDropdown(),
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        var irepBE = CafeBackendServices();
                        if (value == 'all') {
                          irepBE.getSummary('all', null, null).then((value) {
                            setState(() {
                              filteredSummary = value;
                            });
                          });
                        } else if (value == 'daily') {
                          irepBE.getSummary('daily', null, null).then((value) {
                            setState(() {
                              filteredSummary = value;
                            });
                          });
                        } else if (value == 'monthly') {
                          irepBE
                              .getSummary('monthly', null, null)
                              .then((value) {
                            setState(() {
                              filteredSummary = value;
                            });
                          });
                        } else if (value == 'yearly') {
                          irepBE.getSummary('yearly', null, null).then((value) {
                            setState(() {
                              filteredSummary = value;
                            });
                          });
                        }
                        setState(() {
                          selectedSummaryType = value;
                          isRangeDatePicker = value == 'range';
                        });
                      }
                    },
                    value: selectedSummaryType,
                    hint: Text('Pilih Rekap'),
                  ),
                  const Spacer(),
                  isRangeDatePicker
                      ? DateRangeBar(
                          selectedRange: selectedRange,
                          onRangeChanged: (newRange) {
                            setState(() {
                              selectedRange =
                                  newRange; // update the label state
                            });

                            var irepBE = CafeBackendServices();
                            irepBE
                                .getSummary(
                              null,
                              DateFormat('dd-MM-yyyy').format(newRange.start),
                              DateFormat('dd-MM-yyyy').format(newRange.end),
                            )
                                .then((value) {
                              setState(() {
                                filteredSummary = value;
                              });
                            });
                          },
                        )
                      : SizedBox(),
                ],
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              if (dailySummary == null)
                const Center(child: CircularProgressIndicator())
              else
                LayoutBuilder(builder: (context, constraints) {
                  return GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.2,
                    children: [
                      SummaryBoxWidget(
                        title: 'Transaksi',
                        subtitle: '${filteredSummary!.summary.totalOrders}',
                        icon: Icons.receipt_long_rounded,
                        isWidthExpanded: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ListTransaksiDialog(
                              summaryData: filteredSummary!,
                            ),
                          );
                        },
                      ),
                      SummaryBoxWidget(
                        title: 'Item Terjual',
                        subtitle: '${filteredSummary!.summary.totalItems}',
                        icon: Icons.shopping_cart_rounded,
                        isWidthExpanded: false,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => ItemTerjualDialog(
                              summaryData: filteredSummary!,
                            ),
                          );
                        },
                      ),
                      SummaryBoxWidget(
                        title: 'Omzet',
                        subtitle: Helper.rupiahFormatter(
                            filteredSummary!.summary.totalIncome.toDouble()),
                        icon: Icons.payments_rounded,
                        isWidthExpanded: false,
                      ),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
      // ...existing code...
    );
  }
}
