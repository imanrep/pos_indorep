import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/screen/management/components/edit_menu_view.dart';
import 'package:pos_indorep/screen/management/components/menu_list_view.dart';
import 'package:provider/provider.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    final provider = Provider.of<MenuProvider>(context, listen: false);
    _initializeTabController(provider);
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    final provider = Provider.of<MenuProvider>(context, listen: false);
    provider.fetchAllMenus();
  }

  void _updateTabController() {
    final provider = Provider.of<MenuProvider>(context, listen: false);

    if (mounted) {
      int previousIndex = _tabController.index; // Save current index
      int maxIndex = provider.allCategories.length; // Max possible index

      _tabController.dispose(); // Dispose old controller

      _tabController = TabController(
        length: maxIndex + 1, // +1 for "Dashboard"
        vsync: this,
      );

      // Restore the previous index, but ensure it's within bounds
      _tabController.index =
          (previousIndex > maxIndex) ? maxIndex : previousIndex;

      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          provider.clearSelectedMenu();
        }
      });

      setState(() {}); // Trigger UI rebuild
    }
  }

  void _initializeTabController(MenuProvider provider) {
    _tabController = TabController(
      length: provider.allCategories.length + 1, // +1 for "Dashboard"
      vsync: this,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        provider.clearSelectedMenu();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MenuProvider>(context);

    List<Tab> tabs = [
      Tab(text: 'Dashboard'),
      ...provider.allCategories.map((category) =>
          Tab(text: category[0].toUpperCase() + category.substring(1))),
    ];

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 72,
              title: Row(
                children: [
                  Text('Menu Management',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 28.0)),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      var mainProvider =
                          Provider.of<MainProvider>(context, listen: false);
                      provider.fetchAllCategories();
                      provider.fetchAllMenus();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  )
                ],
              ),
              bottom: TabBar(
                tabs: tabs,
                controller: _tabController,
              ),
            ),
            body: Consumer<MenuProvider>(builder: (context, provider, child) {
              return TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kategori',
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.w600)),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: Row(
                                  children: [
                                    Icon(Icons.add),
                                    const SizedBox(width: 8.0),
                                    Text('Tambah Menu',
                                        style: GoogleFonts.inter()),
                                  ],
                                ),
                                onPressed: () {
                                  MenuIrep newMenu = MenuIrep(
                                    available: false,
                                    menuId: 0,
                                    menuName: 'New Menu',
                                    menuType: category,
                                    menuPrice: 0,
                                    menuImage: '',
                                    menuNote: '',
                                    option: [],
                                  );
                                  provider.selectMenu(newMenu);
                                },
                              ),
                              // IconButton(
                              //     onPressed: () async {
                              //       await provider
                              //           .deleteCategory(category.categoryId);
                              //       _updateTabController();
                              //       Future.microtask(
                              //           () => _updateTabController());
                              //     },
                              //     icon: Row(
                              //       children: [
                              //         Icon(Icons.delete_forever),
                              //         Text('Hapus Kategori'),
                              //       ],
                              //     ))
                            ],
                          ),
                          MenuListView(
                            menus: provider.allmenus
                                .where((menu) => menu.menuType == category)
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
            // TextButton(
            //   child: Text('Add'),
            //   onPressed: () {
            //     // provider.addCategory(categoryController.text.toLowerCase());
            //     Navigator.of(context).pop();
            //     Future.microtask(() => _updateTabController());
            //   },
            // ),
          ],
        );
      },
    );
  }
}

class InfoCardListView extends StatelessWidget {
  final List<MenuIrep> menus;
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
            final title = categories[index];
            final qty = provider.getCategoryCount(title);
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            ),
            const Spacer(),
            Text(qty.toString(),
                style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('Menu', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
