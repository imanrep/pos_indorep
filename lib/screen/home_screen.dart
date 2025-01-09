import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/screen/home_pages/main_page.dart';
import 'package:pos_indorep/screen/management/menu_management_page.dart';
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
  final List<NavigationRailDestination> _destinations =
      const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_outlined),
      label: Text('Main'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.receipt_long_rounded),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: Text('Transaksi'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book_outlined),
      label: Text('Menu'),
    ),
  ];

  final List<Widget> _pages = <Widget>[
    MainPage(),
    TransactionPage(),
    MenuManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        shadowColor: Colors.grey,
        title: Row(
          children: [
            Text('INDOREP POS'),
            const Spacer(),
            TextButton(
                onPressed: () {
                  provider.pushExampleMenus();
                },
                child: Icon(Icons.download_rounded)),
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
            Text(DateFormat('HH:mm').format(DateTime.now())),
            Text(
              DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
              style: TextStyle(fontSize: 14),
            ),
          ],
        );
      },
    );
  }
}
