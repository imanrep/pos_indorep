import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/screen/home_pages/main_page.dart';


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
  String currentTime = DateFormat('HH:mm').format(DateTime.now());
  String currentDate = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());

  final List<NavigationRailDestination> _destinations = const <NavigationRailDestination>[
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_filled),
      label: Text('Main'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bookmark_border),
      selectedIcon: Icon(Icons.book),
      label: Text('Second'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.star_border),
      selectedIcon: Icon(Icons.star),
      label: Text('Third'),
    ),
  ];

  final List<Widget> _pages = <Widget>[
    MainPage(),
    Placeholder(),
    Placeholder(),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Row(
          children: [
            Text('INDOREP POS'),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$currentTime'),
                Text('$currentDate', style: TextStyle(fontSize: 14),),
              ],
            ),
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
            leading: showLeading ? FloatingActionButton(
              elevation: 0,
              onPressed: () {
                // Add your onPressed code here!
              },
              child: const Icon(Icons.add),
            ) : null,
            trailing: showTrailing ? IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () {
                // Add your onPressed code here!
              },
            ) : null,
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