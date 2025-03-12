import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/components/add_item_dialog.dart';
import 'package:pos_indorep/screen/pesanan_page/components/payment_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
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
                        AppBar(
                          title: Text('Menu Management'),
                          backgroundColor: Colors.black.withOpacity(0.002),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Handle "All" button press
                                            menuProvider
                                                .filterMenusByCategory("All");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                            ),
                                          ),
                                          child: Text('All'),
                                        ),
                                      ),
                                      ...menuProvider.allCategories
                                          .map((category) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              menuProvider
                                                  .filterMenusByCategory(
                                                      category);
                                              // debugPrint(category.categoryId);
                                              // debugPrint(menuProvider
                                              //     .filteredMenus.length
                                              //     .toString());
                                              // debugPrint(menuProvider
                                              //     .filteredMenus[0].title);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(30.0),
                                              ),
                                            ),
                                            child: Text(
                                              category[0].toUpperCase() +
                                                  category.substring(1),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
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
                              .filteredMenus.length, // total number of items
                          itemBuilder: (context, index) {
                            final item = menuProvider.filteredMenus[index];
                            bool isItemSelected = provider.currentCart.any(
                                (element) => element.menuId == item.menuId);
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddItemDialog(
                                      selectedMenu: item,
                                    );
                                  },
                                );
                                // provider.addItem(item, 1, '');
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
                                            item.menuImage,
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
                                              item.menuName,
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
                                                  item.menuPrice.toDouble()),
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
                                            initiallyExpanded: true,
                                            showTrailingIcon: true,
                                            title: Text(
                                              item.menuName,
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
                                                      'Qty: ${item.qty}',
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontSize: 12.0,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.deepPurple,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8.0),
                                                Text(
                                                  Helper.rupiahFormatter(
                                                      item.subTotal),
                                                  style: const TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage:
                                                  NetworkImage(item.menuImage),
                                              onBackgroundImageError:
                                                  (_, __) {},
                                              child: Image.asset(
                                                'assets/images/default-menu.png',
                                              ),
                                            ),
                                            children: [
                                              // Display selected options
                                              if (item
                                                  .selectedOptions.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          right: 16.0,
                                                          bottom: 8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        "Selected Add-ons:",
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 4.0),
                                                      ...item.selectedOptions
                                                          .map(
                                                              (option) => Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child:
                                                                        Column(
                                                                      children: option
                                                                          .optionValue
                                                                          .where((optVal) => optVal
                                                                              .isSelected) // Filter selected options
                                                                          .map((optVal) =>
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                                                                                child: Text(
                                                                                  "- ${optVal.optionValueName} (+${Helper.rupiahFormatter(optVal.optionValuePrice.toDouble())})",
                                                                                  style: const TextStyle(
                                                                                    fontSize: 13.0,
                                                                                  ),
                                                                                ),
                                                                              ))
                                                                          .toList(),
                                                                    ),
                                                                  )),
                                                    ],
                                                  ),
                                                ),
                                              // Display notes if available
                                              if (item.notes.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          right: 16.0,
                                                          bottom: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Column(
                                                      children: [
                                                        const Text(
                                                          "Notes:",
                                                          style: TextStyle(
                                                            fontSize: 14.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4.0),
                                                        Text(
                                                          item.notes,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13.0,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: IconButton(
                                                  onPressed: () {
                                                    provider.removeItem(item);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
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
                              // const SizedBox(height: 12.0),
                              // SizedBox(
                              //   height: 60,
                              //   child: Column(
                              //     children: [
                              //       Padding(
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 12.0),
                              //         child: TextField(
                              //           style: const TextStyle(
                              //             fontSize: 14.0,
                              //             fontStyle: FontStyle.italic,
                              //             fontWeight: FontWeight.w400,
                              //           ),
                              //           decoration: InputDecoration(
                              //             hintText: 'atas nama...',
                              //             border: OutlineInputBorder(
                              //               borderRadius:
                              //                   BorderRadius.circular(12.0),
                              //               borderSide: BorderSide.none,
                              //             ),
                              //             filled: true,
                              //             fillColor: Colors.white,
                              //             contentPadding: EdgeInsets.symmetric(
                              //                 horizontal: 16.0, vertical: 8.0),
                              //           ),
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
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
                                      paymentMethod: '',
                                      total: provider.totalCurrentCart,
                                      cart: provider.currentCart,
                                    );
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return PaymentDialog(
                                          transaction: transaction,
                                        );
                                      },
                                    );
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
                              const SizedBox(height: 12.0),
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
