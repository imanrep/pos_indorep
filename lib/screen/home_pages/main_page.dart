import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/provider/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(builder: (context, provider, child) {
      return Consumer<MenuProvider>(builder: (context, menuProvider, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.05),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = (constraints.maxWidth / 200).floor();
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // ListView.builder(itemBuilder: (context, index) {
                              //   return Padding(
                              //     padding: const EdgeInsets.symmetric(
                              //         horizontal: 8.0, vertical: 4.0),
                              //     child: ElevatedButton(
                              //       onPressed: () {
                              //         // Add your onPressed code here!
                              //       },
                              //       child: Text(exampleMenu[index].category),
                              //     ),
                              //   );
                              // }),
                            ],
                          ),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                crossAxisCount, // number of items in each row
                            mainAxisSpacing: 24.0, // spacing between rows
                            crossAxisSpacing: 24.0, // spacing between columns
                          ),
                          padding:
                              EdgeInsets.all(8.0), // padding around the grid
                          itemCount: menuProvider
                              .allmenus.length, // total number of items
                          itemBuilder: (context, index) {
                            final item = menuProvider.allmenus[index];
                            bool isItemSelected = provider.currentCart.any(
                                (element) => element.menuId == item.menuId);
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
                                        isItemSelected
                                            ? Container(
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 0.5,
                                                      blurRadius: 1,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                  color: Colors
                                                      .deepPurple.shade300,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(8.0),
                                                    topRight:
                                                        Radius.circular(8.0),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    const Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
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
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 8.0),
                                          Center(
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              Helper.rupiahFormatter(
                                                  item.price),
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
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const VerticalDivider(thickness: 0.5, width: 1),
              Expanded(
                flex: 2,
                child: provider.currentCart.isEmpty
                    ? Center(child: const Text('Keranjang Kosong'))
                    : Column(
                        children: [
                          const SizedBox(height: 12.0),
                          Expanded(
                            child: SingleChildScrollView(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.currentCart.length,
                                itemBuilder: (context, index) {
                                  final item = provider.currentCart[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, bottom: 12),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16.0,
                                              ),
                                            ),
                                            subtitle: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.deepPurple[100],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8.0),
                                                    child: Text(
                                                        'Qty: ${provider.currentCart[index].qty}',
                                                        textAlign:
                                                            TextAlign.center,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.deepPurple,
                                                        )),
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                    Helper.rupiahFormatter(
                                                        provider
                                                            .currentCart[index]
                                                            .subTotal),
                                                    style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w600)),
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
                                              Builder(builder:
                                                  (BuildContext context) {
                                                return Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              provider
                                                                  .incrementQty(
                                                                      item.cartId);
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
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
                                                              provider
                                                                  .decrementQty(
                                                                      item.cartId);
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
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
                                                                  .removeItem(
                                                                      item);
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
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
                                                                  .removeItem(
                                                                      item);
                                                            },
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        4.0),
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
                                                          item.option?.length ??
                                                              0,
                                                      itemBuilder: (context,
                                                          optionIndex) {
                                                        final option =
                                                            item.option?[
                                                                optionIndex];
                                                        if (option == null) {
                                                          return const SizedBox();
                                                        } else {
                                                          return ListTile(
                                                            title: Text(
                                                                option.title),
                                                            subtitle: Row(
                                                              children: option
                                                                  .options
                                                                  .map((e) {
                                                                return Expanded(
                                                                  child: Row(
                                                                    children: [
                                                                      Radio(
                                                                        visualDensity: VisualDensity(
                                                                            horizontal:
                                                                                -4,
                                                                            vertical:
                                                                                -4),
                                                                        value:
                                                                            e,
                                                                        groupValue: provider
                                                                            .currentCart
                                                                            .firstWhere((cartItem) =>
                                                                                cartItem.cartId ==
                                                                                item.cartId)
                                                                            .selectedOption
                                                                            ?.selected,
                                                                        onChanged:
                                                                            (value) {
                                                                          setState(
                                                                              () {
                                                                            provider.setSelectedOptionFromCart(
                                                                                item.cartId,
                                                                                option.optionId,
                                                                                value.toString());
                                                                          });
                                                                        },
                                                                      ),
                                                                      Text(
                                                                        e,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
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
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 12.0),
                              SizedBox(
                                height: 60,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: TextField(
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'atas nama...',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 16.0, vertical: 8.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total',
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600)),
                                    Text(
                                        Helper.rupiahFormatter(
                                            provider.totalCurrentCart),
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    TransactionModel transaction =
                                        TransactionModel(
                                      nama: 'Ujang',
                                      transactionDate:
                                          DateTime.now().millisecondsSinceEpoch,
                                      transactionId: Uuid().v4(),
                                      paymentMethod: 'Cash ',
                                      total: provider.totalCurrentCart,
                                      cart: provider.currentCart,
                                    );
                                    final TransactionProvider
                                        transactionProvider =
                                        Provider.of<TransactionProvider>(
                                            context,
                                            listen: false);
                                    transactionProvider
                                        .addTransaction(transaction);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Bayar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      });
    });
  }
}
