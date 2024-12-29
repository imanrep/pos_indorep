import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/services/firebase_service.dart';
import 'package:provider/provider.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Management'),
      ),
      body: Consumer<MenuProvider>(builder: (context, provider, child) {
        List<String> categories =
            ['All'] + provider.allmenus.map((e) => e.category).toSet().toList();
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Menu Management'),
              Text('Menu Management'),
              Text('Menu Management'),
              Text('Menu Management'),
              Text('Menu Management'),
              Text('Menu Management'),
              InfoCardListView(menus: provider.allmenus),
              CategoryListView(
                categories: categories,
                onCategoryTap: (category) {
                  provider.filterMenusByCategory(category);
                },
              ),
              MenuListView(
                menus: provider.filteredMenus,
                onItemTap: (menu) {},
              ),
            ],
          ),
        );
      }),
    );
  }
}

class InfoCardListView extends StatelessWidget {
  final List<Menu> menus;

  const InfoCardListView({
    Key? key,
    required this.menus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> categories = menus.map((e) => e.category).toSet().toList();
    return SizedBox(
      height: 100.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final title = categories[index];
          final qty = menus.where((menu) => menu.category == title).length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InfoCard(title: title, qty: qty),
          );
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
            Text(title),
            Text(qty.toString()),
          ],
        ),
      ),
    );
  }
}

class MenuListView extends StatelessWidget {
  final List<Menu> menus;
  final Function(Menu) onItemTap;

  const MenuListView({
    Key? key,
    required this.menus,
    required this.onItemTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final item = menus[index];
        return GestureDetector(
          onTap: () => onItemTap(item),
          child: ListTile(
            onTap: () {},
            title: Text(item.title),
            subtitle: Text(Helper.rupiahFormatter(item.price)),
            leading: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(item.image)),
          ),
        );
      },
    );
  }
}

class CategoryListView extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategoryTap;

  const CategoryListView({
    Key? key,
    required this.categories,
    required this.onCategoryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CategoryCard(
              category: category,
              onTap: () => onCategoryTap(category),
            ),
          );
        },
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String category;
  final Function() onTap;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class MenuGridView extends StatelessWidget {
  final int crossAxisCount;
  final List<Menu> menus;
  final Function(Menu) onItemTap;
  const MenuGridView(
      {super.key,
      required this.crossAxisCount,
      required this.menus,
      required this.onItemTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, provider, child) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 24.0,
        ),
        padding: EdgeInsets.all(8.0),
        itemCount: menus.length,
        itemBuilder: (context, index) {
          final item = menus[index];
          return GestureDetector(
            onTap: () {
              onItemTap(item);
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: Image.network(
                          item.image,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            item.title,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        Center(
                          child: Text(
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            Helper.rupiahFormatter(item.price),
                            style: const TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
