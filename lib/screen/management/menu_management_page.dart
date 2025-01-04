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
  void initState() {
    super.initState();
    final provider = Provider.of<MenuProvider>(context, listen: false);
    provider.fetchAllMenus();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);

    List<Tab> tabs = [
      Tab(text: 'Dashboard'),
      ...provider.allCategories.map((category) => Tab(
          text: category.categoryId[0].toUpperCase() +
              category.categoryId.substring(1))),
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
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kategori',
                                style: TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 16.0),
                            InfoCardListView(
                              menus: provider.allmenus,
                              onAddCategory: () {
                                _showAddCategoryDialog(context, provider);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    ...provider.allCategories.map((category) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    Menu newMenu = Menu(
                                      menuId: '',
                                      createdAt:
                                          DateTime.now().millisecondsSinceEpoch,
                                      title: 'New Menu',
                                      category: Category(
                                          categoryId: category.categoryId,
                                          createdAt: category.createdAt),
                                      price: 0,
                                      image: '',
                                      desc: '',
                                      tag: [],
                                      available: true,
                                    );
                                    provider.selectMenu(newMenu);
                                  },
                                ),
                                IconButton(
                                    onPressed: () {
                                      provider
                                          .deleteCategory(category.categoryId);
                                    },
                                    icon: Icon(Icons.delete_forever))
                              ],
                            ),
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
                    }),
                  ],
                );
              }),
            ),
          ),
        ),
        VerticalDivider(),
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

void _showAddCategoryDialog(BuildContext context, MenuProvider provider) {
  final TextEditingController categoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Tambah Kategori'),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(hintText: '...'),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
            onPressed: () {
              provider.addCategory(categoryController.text.toLowerCase());
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
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
    final provider = Provider.of<MenuProvider>(context);
    final categories = provider.allCategories;
    final menus = provider.allmenus;
    debugPrint(categories.length.toString());

    return SizedBox(
      height: 100.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
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
                          'Tambah Kategori',
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
            final title = categories[index].categoryId;
            final qty = menus.where((menu) => menu.category == title).length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: InfoCategoryCard(
                title: title[0].toUpperCase() + title.substring(1),
                qty: qty,
              ),
            );
          }
        },
      ),
    );
  }
}

class InfoCategoryCard extends StatelessWidget {
  final String title;
  final int qty;

  const InfoCategoryCard({
    super.key,
    required this.title,
    required this.qty,
  });

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
