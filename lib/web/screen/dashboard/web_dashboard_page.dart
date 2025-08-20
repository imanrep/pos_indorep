import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_dashboard_provider.dart';
import 'package:pos_indorep/web/components/fluent_date_bar.dart';
import 'package:pos_indorep/web/screen/dashboard/components/daily_summary_card.dart';
import 'package:pos_indorep/web/screen/dashboard/components/food_orders_card.dart';
import 'package:pos_indorep/web/screen/dashboard/components/web_dashboard_card.dart';
import 'package:pos_indorep/web/screen/dashboard/components/detail_page/detail_transaksi_page.dart';
import 'package:provider/provider.dart';

class WebDashboardPage extends StatefulWidget {
  const WebDashboardPage({super.key});

  @override
  State<WebDashboardPage> createState() => _WebDashboardPageState();
}

class _WebDashboardPageState extends State<WebDashboardPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Fetch data initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WarnetDashboardProvider>(context, listen: false).init();
    });

    // Set up a periodic timer to fetch data every 5 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      Provider.of<WarnetDashboardProvider>(context, listen: false).init();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

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
        Consumer<WarnetDashboardProvider>(builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FoodOrdersCard(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Summary Harian',
                  style: FluentTheme.of(context).typography.subtitle!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
              ),
              const SizedBox(height: 24),
              FluentDateBar(
                selectedDate: provider.selectedSummaryDate,
                onDateChanged: provider.onSummaryDateChanged,
              ),
              const SizedBox(height: 16),
              DailySummaryCard(),
              const SizedBox(height: 16),
              Divider(),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Summary Utama',
                  style: FluentTheme.of(context).typography.subtitle!.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  bool isWide = constraints.maxWidth > 800;
                  double cardWidth = isWide
                      ? constraints.maxWidth /
                          4 // Four cards per row for wide screens
                      : constraints.maxWidth /
                          2; // Two cards per row for small screens

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
                      subtitle: provider
                              .allTimeSalesSummaryWarnet?.summary.totalOrders
                              .toString() ??
                          'No Data Available',
                      icon: FluentIcons.receipt_processing,
                      isWidthExpanded: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          FluentPageRoute(
                            builder: (context) => DetailTransaksiPage(),
                          ),
                        );
                      },
                    ),
                    WebDashboardCard(
                      title: "Transaksi Kulkas",
                      subtitle: "0",
                      icon: FluentIcons.column,
                      isWidthExpanded: false,
                    ),
                    WebDashboardCard(
                      title: "Omzet Warnet",
                      subtitle: Helper.rupiahFormatterTwo(provider
                              .allTimeSalesSummaryWarnet?.summary.totalIncome ??
                          0),
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

                  // Divide cards into rows
                  List<List<Widget>> rows = [];
                  int cardsPerRow = isWide ? 4 : 2;
                  for (int i = 0; i < cards.length; i += cardsPerRow) {
                    rows.add(cards.sublist(
                        i,
                        i + cardsPerRow > cards.length
                            ? cards.length
                            : i + cardsPerRow));
                  }

                  if (isWide) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rows.map((row) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: row.map((card) {
                            return SizedBox(
                              width: cardWidth,
                              child: card,
                            );
                          }).toList(),
                        );
                      }).toList(),
                    );
                  } else {
                    // For small screens, create rows of 2 cards
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: rows.map((row) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: row.map((card) {
                            return SizedBox(
                              width: cardWidth,
                              child: card,
                            );
                          }).toList(),
                        );
                      }).toList(),
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
