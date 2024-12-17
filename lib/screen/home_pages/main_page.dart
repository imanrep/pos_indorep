import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:pos_indorep/model/example_data.dart';
import 'package:pos_indorep/model/model.dart';
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
                      provider.addItem(item, 1, '');
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
            child: provider.currentCart.isEmpty
                ? Center(child: const Text('No item selected'))
                : Column(
                    children: [
                      SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.currentCart.length,
                          itemBuilder: (context, index) {
                            final item = provider.currentCart[index];
                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Theme(
                                    data: ThemeData().copyWith(
                                        dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      showTrailingIcon: true,
                                      title: Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      subtitle: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple[100],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0),
                                              child: Text(
                                                'Qty: ${provider.currentCart[index].qty}',
                                                textAlign: TextAlign.center,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(
                                              'Rp. ${provider.currentCart[index].subTotal.toStringAsFixed(2)}'),
                                        ],
                                      ),
                                      leading: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Image.network(
                                          item.image,
                                          height: 54,
                                          width: 54,
                                        ),
                                      ),
                                      children: <Widget>[
                                        Builder(
                                            builder: (BuildContext context) {
                                          return Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        provider.incrementQty(
                                                            item.cartId);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Icon(
                                                              Icons
                                                                  .plus_one_rounded,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        provider.decrementQty(
                                                            item.cartId);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Icon(
                                                              Icons
                                                                  .exposure_minus_1_rounded,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        provider
                                                            .removeItem(item);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Icon(
                                                              Icons
                                                                  .edit_rounded,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        provider
                                                            .removeItem(item);
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          child: Icon(
                                                              Icons
                                                                  .delete_rounded,
                                                              color: Colors
                                                                  .black54),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    item.option?.length ?? 0,
                                                itemBuilder:
                                                    (context, optionIndex) {
                                                  final option =
                                                      item.option?[optionIndex];
                                                  if (option == null) {
                                                    return const SizedBox();
                                                  } else {
                                                    return ListTile(
                                                      title: Text(option.title),
                                                      subtitle: Row(
                                                        children: option.options
                                                            .map((e) {
                                                          return Expanded(
                                                            child: Row(
                                                              children: [
                                                                Radio(
                                                                  visualDensity:
                                                                      VisualDensity(
                                                                          horizontal:
                                                                              -4,
                                                                          vertical:
                                                                              -4),
                                                                  value: e,
                                                                  groupValue: provider
                                                                      .currentCart
                                                                      .firstWhere((cartItem) =>
                                                                          cartItem
                                                                              .cartId ==
                                                                          item.cartId)
                                                                      .selectedOption
                                                                      ?.selected,
                                                                  onChanged:
                                                                      (value) {
                                                                    setState(
                                                                        () {
                                                                      provider.setSelectedOptionFromCart(
                                                                          item
                                                                              .cartId,
                                                                          option
                                                                              .optionId,
                                                                          value
                                                                              .toString());
                                                                    });
                                                                  },
                                                                ),
                                                                Text(
                                                                  e,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16.0),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ),
                                                    );
                                                  }
                                                },
                                              )
                                            ],
                                          );
                                        })
                                      ],
                                    ),
                                  )),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      );
    });
  }
}
