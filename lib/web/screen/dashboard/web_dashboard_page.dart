import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/provider/web/warnet_backend_provider.dart';
import 'package:pos_indorep/screen/transaction/components/widget/date_bar.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:pos_indorep/web/screen/dashboard/components/web_dashboard_card.dart';
import 'package:pos_indorep/web/screen/transaksi/components/beverages_transaction_list.dart';
import 'package:pos_indorep/web/screen/transaksi/components/warnet_transaction_list.dart';
import 'package:provider/provider.dart';

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({super.key});

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  final WebServices _services = WebServices();
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: PageHeader(
        title: Text(
          'Dashboard',
          style: FluentTheme.of(context).typography.title,
        ),
      ),
      children: [
        Consumer<WarnetBackendProvider>(builder: (context, provider, child) {
          return Column(
            children: [
              DateBar(
                selectedDate: provider.selectedSummaryDate,
                onDateChanged: provider.onSummaryDateChanged,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 7.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 800;
                    double cardWidth = 200; // Set your card width here
                    int cardsPerRow = isWide
                        ? (constraints.maxWidth / (cardWidth + 12)).floor()
                        : 1;

                    List<Widget> cards = [
                      WebDashboardCard(
                        title: "Jumlah Member",
                        subtitle: provider.jumlahMember.toString(),
                        icon: FluentIcons.user_gauge,
                        isWidthExpanded: false,
                      ),
                      WebDashboardCard(
                        title: "Jumlah Item Kulkas",
                        subtitle: provider.jumlahItemKulkas.toString(),
                        icon: FluentIcons.eat_drink,
                        isWidthExpanded: false,
                      ),
                      WebDashboardCard(
                        title: "Transaksi Warnet",
                        subtitle: provider.totalTransaksiWarnet.toString(),
                        icon: FluentIcons.receipt_processing,
                        isWidthExpanded: false,
                      ),
                      WebDashboardCard(
                        title: "Transaksi Kulkas",
                        subtitle: "0",
                        icon: FluentIcons.column,
                        isWidthExpanded: false,
                      ),
                      WebDashboardCard(
                        title: "Omzet Warnet",
                        subtitle: "0",
                        icon: FluentIcons.money,
                        isWidthExpanded: false,
                      ),
                      WebDashboardCard(
                        title: "Omzet Kulkas",
                        subtitle: "0",
                        icon: FluentIcons.circle_dollar,
                        isWidthExpanded: false,
                      ),
                    ];

                    return Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: isWide ? constraints.maxWidth : double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          spacing: 12,
                          runSpacing: 12,
                          children: cards
                              .map((card) =>
                                  SizedBox(width: cardWidth, child: card))
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 800;
                  Widget warnetSection = SizedBox(
                    width: isWide
                        ? constraints.maxWidth / 2 - 12
                        : double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _services.getWarnetEntriesByDate(DateTime.now()),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CupertinoActivityIndicator());
                        }
                        return Column(
                          children: [
                            WarnetTransactionList(),
                          ],
                        );
                      },
                    ),
                  );
                  Widget beveragesSection = SizedBox(
                    width: isWide
                        ? constraints.maxWidth / 2 - 12
                        : double.infinity,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _services.getWarnetEntriesByDate(DateTime.now()),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CupertinoActivityIndicator());
                        }
                        return Column(
                          children: [
                            BeveragesTransactionList(),
                          ],
                        );
                      },
                    ),
                  );
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        warnetSection,
                        beveragesSection,
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        warnetSection,
                        beveragesSection,
                      ],
                    );
                  }
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
