import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/screen/pesanan_page/pesanan_page.dart';
import 'package:pos_indorep/screen/management/menu_management_page.dart';
import 'package:pos_indorep/screen/settings/settings_page.dart';
import 'package:pos_indorep/screen/transaction/transaction_page.dart';

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
  final List<NavigationRailDestination> _destinations =
      const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book_outlined),
      label: Text('Pesanan'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_rounded),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: Text('Transaksi'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.lunch_dining_outlined),
      selectedIcon: Icon(Icons.lunch_dining_outlined),
      label: Text('Menu'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.settings_rounded),
      selectedIcon: Icon(Icons.settings_rounded),
      label: Text('Settings'),
    ),
    // NavigationRailDestination(
    //   icon: Icon(Icons.table_bar_outlined),
    //   selectedIcon: Icon(Icons.table_bar_outlined),
    //   label: Text('Meja'),
    // ),
  ];

  final List<Widget> _pages = <Widget>[
    PesananPage(),
    TransactionPage(),
    MenuManagementPage(),
    SettingsPage(),
    // MejaPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<MenuProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.facebook_rounded, color: IndorepColor.primary, size: 38),
            const SizedBox(width: 8),
            Text('INDOREP CAFE',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                )),
            const Spacer(),
            ClockWidget()
          ],
        ),
      ),
      body: Row(
        children: <Widget>[
          NavigationRail(
            minWidth: 100,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: labelType,
            leading: showLeading
                ? FloatingActionButton(
                    elevation: 0,
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                    child: const Icon(Icons.add),
                  )
                : null,
            trailing: showTrailing
                ? IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      // Add your onPressed code here!
                    },
                  )
                : null,
            destinations: _destinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: _pages[_selectedIndex],
          )
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
              DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ],
        );
      },
    );
  }
}
