import 'package:fluent_ui/fluent_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/provider/web/web_main_provider.dart';
import 'package:pos_indorep/web/screen/dashboard/web_dashboard_page.dart';
import 'package:pos_indorep/web/screen/pc_management/pc_management_screen.dart';
import 'package:pos_indorep/web/screen/transaksi/transaksi_page.dart';
import 'package:provider/provider.dart';

class WarnetHomeScreen extends StatefulWidget {
  const WarnetHomeScreen({super.key});

  @override
  _WarnetHomeScreenState createState() => _WarnetHomeScreenState();
}

class _WarnetHomeScreenState extends State<WarnetHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<WebMainProvider>(builder: (context, provider, child) {
      return NavigationView(
        appBar: NavigationAppBar(
          title: Row(
            children: [
              Image.asset('assets/images/app_icon.png', width: 38, height: 38),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'INDOREP Net Dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          actions: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Shift OP : ',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ComboBox<String>(
                  value: provider.currentOperator,
                  items: provider.operators
                      .map((op) => ComboBoxItem(value: op, child: Text(op)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setCurrentOperator(value);
                    }
                  },
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        pane: NavigationPane(
          selected: _selectedIndex,
          onChanged: (index) => setState(() => _selectedIndex = index),
          displayMode: PaneDisplayMode.compact,
          items: [
            PaneItem(
                icon: const Icon(FluentIcons.home),
                title: const Text('Dashboard'),
                body: WebDashboardPage()),
            PaneItemSeparator(),
            PaneItem(
                icon: const Icon(FluentIcons.receipt_processing),
                title: const Text('Transaksi'),
                body: TransaksiPage()),
            PaneItem(
              icon: const Icon(FluentIcons.pc1),
              title: const Text('PC Management'),
              body: const PcManagementScreen(),
            ),
            // Add more PaneItems as needed
          ],
        ),
      );
    });
  }
}
