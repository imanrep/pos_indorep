import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/screen/management/components/edit_menu_view.dart';
import 'package:pos_indorep/screen/management/components/menu_list_view.dart';
import 'package:provider/provider.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);
    List<Tab> tabs = [
      Tab(text: 'Dashboard'),
      ...provider.allCategories.map((category) {
        return Tab(text: category);
      }),
    ];

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Menu Management'),
                bottom: TabBar(tabs: tabs),
              ),
              body: Consumer<MenuProvider>(builder: (context, provider, child) {
                return TabBarView(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoCardListView(
                            menus: provider.allmenus,
                            onAddCategory: () {},
                          ),
                        ],
                      ),
                    ),
                    ...provider.allCategories.map((category) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MenuListView(
                              menus: provider.filteredMenus
                                  .where((menu) => menu.category == category)
                                  .toList(),
                              onItemTap: (menu) {
                                provider.selectMenu(menu);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Consumer<MenuProvider>(builder: (context, provider, child) {
            if (provider.selectedMenu == null) {
              return Center(child: Text('Select a menu item to view details'));
            } else {
              return EditMenuView(menu: provider.selectedMenu!);
            }
          }),
        ),
      ],
    );
  }
}

class InfoCardListView extends StatelessWidget {
  final List<Menu> menus;
  final Function() onAddCategory;

  const InfoCardListView({
    super.key,
    required this.menus,
    required this.onAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    List<String> categories = menus.map((e) => e.category).toSet().toList();
    return SizedBox(
      height: 100.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length +
            1, // Add one more item for the "Add New Category" card
        itemBuilder: (context, index) {
          if (index == categories.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GestureDetector(
                onTap: onAddCategory,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 24.0),
                        SizedBox(height: 8.0),
                        Text(
                          'Tambah',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            final title = categories[index];
            final qty = menus.where((menu) => menu.category == title).length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InfoCard(title: title, qty: qty),
            );
          }
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final int qty;

  const InfoCard({
    Key? key,
    required this.title,
    required this.qty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('Total Menu'),
            const Spacer(),
            Text(qty.toString()),
            const Spacer(),
            Text(title),
          ],
        ),
      ),
    );
  }
}
