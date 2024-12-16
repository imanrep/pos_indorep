import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:pos_indorep/model/menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedMenuIndex = 0;

  final List<String> _menus = [
    'Menu 1',
    'Menu 2',
    'Menu 3',
  ];

  final List<Widget> _menuPages = [
    Center(child: Text('Content for Menu 1')),
    Center(child: Text('Content for Menu 2')),
    Center(child: Text('Content for Menu 3')),
  ];

  List<Menu> exampleMenu = [
    Menu(
      title: 'Bakmie Ayam Jawa Spesial Telur',
      category: 'Makanan',
      tag: ['Mie'],
      image:
          'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
      desc: 'Description for Menu 1',
      price: 10000,
      option: Option(
        title: 'Option 1',
        options: ['Option 1.1', 'Option 1.2', 'Option 1.3'],
      ),
    ),
    Menu(
      title: 'Nasi Goreng Bu Indah',
      category: 'Makanan',
      tag: ['Nasi'],
      image:
          'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
      desc: 'Description for Menu 2',
      price: 20000,
      option: Option(
        title: 'Option 2',
        options: ['Option 2.1', 'Option 2.2', 'Option 2.3'],
      ),
    ),
    Menu(
      title: 'Ayam Geprek',
      category: 'Ayam',
      tag: [''],
      image:
          'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
      desc: 'Description for Menu 3',
      price: 30000,
      option: Option(
        title: 'Option 3',
        options: ['Option 3.1', 'Option 3.2', 'Option 3.3'],
      ),
    ),
    Menu(
      title: 'Pempek Palembang Khas Banyuwangi',
      category: 'Makanan',
      tag: ['Cemilan'],
      image:
          'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
      desc: 'Description for Menu 3',
      price: 30000,
      option: Option(
        title: 'Option 3',
        options: ['Option 3.1', 'Option 3.2', 'Option 3.3'],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = (constraints.maxWidth / 200).floor();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount, // number of items in each row
                mainAxisSpacing: 24.0, // spacing between rows
                crossAxisSpacing: 24.0, // spacing between columns
              ),
              padding: EdgeInsets.all(8.0), // padding around the grid
              itemCount: exampleMenu.length, // total number of items
              itemBuilder: (context, index) {
                final item = exampleMenu[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                        child: ImageNetwork(
                          image: item.image,
                          width: 220,
                          height: 120,
                          fitWeb: BoxFitWeb.cover,
                        ),
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
                                  fontWeight: FontWeight.bold,
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
                            Center(
                              child: Text(
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                'Rp. ${item.price.toStringAsFixed(2)}',
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
                );
              },
            );
          }),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(
          flex: 2,
          child: _menuPages[_selectedMenuIndex],
        ),
      ],
    );
  }
}
