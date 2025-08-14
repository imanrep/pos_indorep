import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:pos_indorep/screen/dashboard/tablet_dashoard_page.dart';
import 'package:pos_indorep/screen/pesanan_page/pesanan_page.dart';
import 'package:pos_indorep/screen/management/menu_management_page.dart';
import 'package:pos_indorep/screen/settings/settings_page.dart';
import 'package:pos_indorep/screen/transaction/transaction_page.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  bool showTrailing = false;
  double groupAlignment = -1.0;

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<MenuProvider>(context);
    final List<NavigationRailDestination> _destinations =
        <NavigationRailDestination>[
      NavigationRailDestination(
        icon: Icon(Icons.space_dashboard_outlined),
        selectedIcon: Icon(Icons.space_dashboard_rounded),
        label: Text('Dashboard'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.book_outlined),
        selectedIcon: Icon(Icons.book),
        label: Text('Pesanan'),
      ),
      NavigationRailDestination(
        icon: Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
          if (transactionProvider.hasNewData) {
            return Stack(
              children: [
                Icon(Icons.receipt_long_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.circle, color: Colors.red, size: 12),
                ),
              ],
            );
          } else {
            return Icon(Icons.receipt_long_outlined);
          }
        }),
        selectedIcon: Consumer<TransactionProvider>(
            builder: (context, transactionProvider, child) {
          if (transactionProvider.hasNewData) {
            return Stack(
              children: [
                Icon(Icons.receipt_long),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Icon(Icons.circle, color: Colors.red, size: 12),
                ),
              ],
            );
          } else {
            return Icon(Icons.receipt_long);
          }
        }),
        label: Text('Transaksi'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.lunch_dining_outlined),
        selectedIcon: Icon(Icons.lunch_dining),
        label: Text('Menu'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings_rounded),
        label: Text('Settings'),
      ),
    ];

    final List<Widget> _pages = <Widget>[
      TabletDashboardPage(),
      PesananPage(),
      TransactionPage(),
      MenuManagementPage(),
      SettingsPage(),
      // MejaPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/images/app_icon.png', width: 48, height: 48),
            const SizedBox(width: 8),
            Text('INDOREP CAFE',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
            const Spacer(),
            ClockWidget()
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: NavigationRail(
                  minWidth: 100,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: labelType,
                  destinations: _destinations,
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('HH:mm').format(DateTime.now()),
              style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            ),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now()),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        );
      },
    );
  }
}

class _ReceiptBottomSheet extends StatefulWidget {
  const _ReceiptBottomSheet();

  @override
  State<_ReceiptBottomSheet> createState() => _ReceiptBottomSheetState();
}

class _ReceiptBottomSheetState extends State<_ReceiptBottomSheet> {
  ReceiptController? controller;
  String? address;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controllerScroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text('Receipt',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    final selected =
                        await FlutterBluetoothPrinter.selectDevice(context);
                    if (selected != null) {
                      setState(() {
                        address = selected.address;
                      });
                    }
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                controller: controllerScroll,
                child: Receipt(
                  backgroundColor: Colors.grey.shade200,
                  builder: (context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Image.asset(
                        //   'assets/logo.webp',
                        //   fit: BoxFit.fitHeight,
                        //   height: 200,
                        // ),
                        const SizedBox(height: 8),
                        const FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            'PURCHASE RECEIPT',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(thickness: 2),
                        Table(
                          columnWidths: const {
                            1: IntrinsicColumnWidth(),
                          },
                          children: const [
                            TableRow(
                                children: [Text('ORANGE JUICE'), Text(r'$2')]),
                            TableRow(children: [
                              Text('CAPPUCINO MEDIUM SIZE'),
                              Text(r'$2.9')
                            ]),
                            TableRow(
                                children: [Text('BEEF PIZZA'), Text(r'$15.9')]),
                            TableRow(
                                children: [Text('ORANGE JUICE'), Text(r'$2')]),
                            TableRow(children: [
                              Text('CAPPUCINO MEDIUM SIZE'),
                              Text(r'$2.9')
                            ]),
                            TableRow(
                                children: [Text('BEEF PIZZA'), Text(r'$15.9')]),
                          ],
                        ),
                        const Divider(thickness: 2),
                        const FittedBox(
                          fit: BoxFit.cover,
                          child: Row(
                            children: [
                              Text('TOTAL',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                              SizedBox(width: 16),
                              Text(r'$200',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const Divider(thickness: 2),
                        const Text('Thank you for your purchase!'),
                        const SizedBox(height: 24),
                        // Center(
                        //   child: Image.asset(
                        //     'assets/qrcode.png',
                        //     width: 150,
                        //   ),
                        // ),
                      ],
                    );
                  },
                  onInitialized: (ctrl) => setState(() => controller = ctrl),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SafeArea(
              top: false,
              child: Row(
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
