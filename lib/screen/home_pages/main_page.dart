import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:pos_indorep/model/example_data.dart';
import 'package:pos_indorep/model/menu.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    var example = ExampleData();
    var exampleMenu = example.exampleMenu;
    return Consumer<MainProvider>(builder: (context, provider, child) {
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
                  return GestureDetector(
                    onTap: () {
                      provider.addItem(item);
                    },
                    child: Card(
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
                            child: Image.network(
                              item.image,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Spacer(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
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
                    ),
                  );
                },
              );
            }),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            flex: 2,
            child: Center(
                child: provider.selectedItems.isEmpty
                    ? const Text('No item selected')
                    : ListView.builder(
                        itemCount: provider.selectedItems.length,
                        itemBuilder: (context, index) {
                          final item = provider.selectedItems[index];

                          return ListTile(
                            title: Text(item.title),
                            subtitle:
                                Text('Rp. ${item.price.toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                provider.removeItem(item);
                              },
                            ),
                          );
                        },
                      )),
          ),
        ],
      );
    });
  }
}
