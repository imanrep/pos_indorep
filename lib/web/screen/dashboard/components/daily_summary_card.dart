import 'package:fluent_ui/fluent_ui.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_dashboard_provider.dart';
import 'package:pos_indorep/web/screen/dashboard/components/web_dashboard_card.dart';
import 'package:pos_indorep/web/screen/dashboard/components/detail_page/detail_transaksi_page.dart';
import 'package:provider/provider.dart';

class DailySummaryCard extends StatefulWidget {
  const DailySummaryCard({super.key});

  @override
  State<DailySummaryCard> createState() => _DailySummaryCardState();
}

class _DailySummaryCardState extends State<DailySummaryCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<WarnetDashboardProvider>(
        builder: (context, provider, child) {
      return LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          double cardWidth = isWide
              ? constraints.maxWidth / 4 // Four cards per row for wide screens
              : constraints.maxWidth / 2; // Two cards per row for small screens

          List<Widget> cards = [
            WebDashboardCard(
              title: "PC Tersedia",
              subtitle: provider.totalPCAvailable.toString(),
              icon: FluentIcons.pc1,
              isWidthExpanded: false,
            ),
            WebDashboardCard(
              title: "PC Aktif",
              subtitle: provider.totalPCOnline.toString(),
              icon: FluentIcons.this_p_c,
              isWidthExpanded: false,
            ),
            WebDashboardCard(
              title: "Transaksi Warnet",
              subtitle: provider.dailySalesSummaryWarnet?.summary.totalOrders
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
              subtitle: Helper.rupiahFormatterTwo(
                  provider.dailySalesSummaryWarnet?.summary.totalIncome ?? 0),
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
      );
    });
  }
}
