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
  int _selectedIndex = 1;
  final moreOptionsController = FlyoutController();

  @override
  Widget build(BuildContext context) {
    return Consumer<WebMainProvider>(builder: (context, provider, child) {
      List<MenuFlyoutItem> menuItemsOffline = [
        MenuFlyoutItem(
          leading: const Icon(FluentIcons.error),
          text: Text('Fix API Key'),
          onPressed: () => updateApiKeyDialog(context),
        )
      ];

      List<MenuFlyoutItem> menuItems = [
        MenuFlyoutItem(
          leading: provider.serverOnline
              ? Icon(
                  FluentIcons.check_mark,
                  color: Colors.green,
                )
              : const Icon(FluentIcons.error),
          text: Text('Server Status'),
          onPressed: () {},
        ),
      ];

      return NavigationView(
        appBar: NavigationAppBar(
          leading:
              Image.asset('assets/images/app_icon.png', width: 38, height: 38),
          title: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 480) {
                      return Text(
                        'INDOREP Net Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    } else {
                      return Text(
                        'Dashboard',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          actions: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Text(
                //   'Shift : ',
                //   style: GoogleFonts.inter(
                //       fontSize: 16, fontWeight: FontWeight.w600),
                // ),
                // const SizedBox(width: 8),
                // ComboBox<String>(
                //   value: provider.currentOperator,
                //   items: provider.operators
                //       .map((op) => ComboBoxItem(value: op, child: Text(op)))
                //       .toList(),
                //   onChanged: (value) {
                //     if (value != null) {
                //       provider.setCurrentOperator(value);
                //     }
                //   },
                // ),
                SizedBox(
                  height: 34,
                  child: Button(
                    child: Icon(FluentIcons.refresh),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 16),
                FlyoutTarget(
                    controller: moreOptionsController,
                    child: Button(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            provider.serverOnline
                                ? CircleAvatar(
                                    backgroundColor: Colors.green,
                                    radius: 8,
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 8,
                                  ),
                            const SizedBox(width: 8),
                            provider.serverOnline
                                ? Text('Online')
                                : const Text('Offline'),
                          ],
                        ),
                      ),
                      onPressed: () {
                        moreOptionsController.showFlyout(
                          autoModeConfiguration: FlyoutAutoConfiguration(
                            preferredMode: FlyoutPlacementMode.bottomCenter,
                          ),
                          barrierDismissible: true,
                          dismissOnPointerMoveAway: false,
                          dismissWithEsc: true,
                          builder: (context) {
                            return MenuFlyout(
                                items: provider.serverOnline
                                    ? menuItems
                                    : menuItemsOffline);
                          },
                        );
                      },
                    )),
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
          ],
        ),
      );
    });
  }

  void updateApiKeyDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => ContentDialog(
        title: Text('Update API Key'),
        content: InfoLabel(
          label: 'Input new API key:',
          child: SizedBox(
            height: 32,
            child: TextBox(
              placeholder: 'eyJ...',
            ),
          ),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
          FilledButton(
              child: const Text('Update'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, 'API Key Updated');
              }),
        ],
      ),
    );
    setState(() {});
  }
}
