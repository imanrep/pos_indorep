import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/components/add_item_dialog.dart';
import 'package:pos_indorep/screen/pesanan_page/components/category_button.dart';
import 'package:pos_indorep/screen/pesanan_page/components/payment_dialog.dart';
import 'package:pos_indorep/services/irepbe_services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    final provider = Provider.of<MenuProvider>(context, listen: false);
    provider.fetchAllMenus();
  }

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Text('Pesanan',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 28.0)),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  menuProvider.fetchAllCategories();
                                  menuProvider.fetchAllMenus();
                                },
                                icon: const Icon(Icons.refresh_rounded),
                              )
                            ],
                          ),
                        ),
                        Align(
                            alignment: Alignment.topLeft, child: CategoryRow()),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                crossAxisCount, // number of items in each row
                            mainAxisSpacing: 16.0, // spacing between rows
                            crossAxisSpacing: 16.0, // spacing between columns
                          ),
                          padding:
                              EdgeInsets.all(32.0), // padding around the grid
                          itemCount: menuProvider.filteredMenus.isNotEmpty
                              ? menuProvider.filteredMenus.length
                              : menuProvider
                                  .allmenus.length, // total number of items
                          itemBuilder: (context, index) {
                            final item = menuProvider.filteredMenus.isNotEmpty
                                ? menuProvider.filteredMenus[index]
                                : menuProvider.allmenus[index];
                            bool isItemSelected = provider.currentCart.any(
                                (element) => element.menuId == item.menuId);
                            return GestureDetector(
                              onTap: item.available
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddItemDialog(
                                            selectedMenu: item,
                                          );
                                        },
                                      );
                                      // provider.addItem(item, 1, '');
                                    }
                                  : () {
                                      Fluttertoast.showToast(
                                        msg: 'Menu tidak tersedia',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        fontSize: 16.0,
                                      );
                                    },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Spacer(),
                                        ClipOval(
                                          child: Image.network(
                                            item.menuImage,
                                            height: 100,
                                            width:
                                                100, // Set width equal to height for a perfect circle
                                            fit: BoxFit
                                                .cover, // Use BoxFit.cover to ensure the image fills the circle
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return ClipOval(
                                                child: Image.asset(
                                                  'assets/images/default-menu.png', // Your default image path
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const Spacer(),
                                        Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text(
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              item.menuName,
                                              style: GoogleFonts.inter(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            Helper.rupiahFormatter(
                                                item.menuPrice.toDouble()),
                                            style: GoogleFonts.inter(
                                              fontSize: 13.0,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                    item.available
                                        ? Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Icon(
                                              isItemSelected
                                                  ? Icons.check_circle_rounded
                                                  : Icons.add_circle_rounded,
                                              color: isItemSelected
                                                  ? Colors.green
                                                  : IndorepColor.primary,
                                              size: 24,
                                            ),
                                          )
                                        : Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                color:
                                                    Colors.red.withOpacity(0.5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8),
                                              child: const Text(
                                                'Habis',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Keranjang',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 28.0)),
                              ],
                            ),
                          ),
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
                                    child: Theme(
                                      data: ThemeData().copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(
                                              0.1), // Dark gray background (adjust as needed)
                                          borderRadius: BorderRadius.circular(
                                              12), // Rounded corners
                                        ),
                                        child: ExpansionTile(
                                          backgroundColor: Colors.transparent,
                                          initiallyExpanded: true,
                                          showTrailingIcon: true,
                                          title: Text(
                                            item.menuName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.white),
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Text(
                                                    'Qty: ${item.qty}',
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.deepPurple,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Expanded(
                                                child: Text(
                                                  Helper.rupiahFormatter(
                                                      item.subTotal),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                      fontSize: 12.0,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                          leading: ClipOval(
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Image.network(
                                                item.menuImage,
                                                height: 100,
                                                width: double.infinity,
                                                fit: BoxFit.fitHeight,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Image.asset(
                                                    'assets/images/default-menu.png',
                                                    height: 100,
                                                    width: double.infinity,
                                                    fit: BoxFit.fitHeight,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          children: [
                                            // Display selected options
                                            if (item.selectedOptions.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    bottom: 8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Add-ons:",
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4.0),
                                                    ...item.selectedOptions
                                                        .map((option) => Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: option
                                                                    .optionValue
                                                                    .where((optVal) =>
                                                                        optVal
                                                                            .isSelected)
                                                                    .map((optVal) =>
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 8.0,
                                                                              bottom: 2.0),
                                                                          child:
                                                                              Text(
                                                                            "- ${optVal.optionValueName} (+${Helper.rupiahFormatter(optVal.optionValuePrice.toDouble())})",
                                                                            style:
                                                                                GoogleFonts.inter(fontSize: 13.0, fontWeight: FontWeight.w600),
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
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16.0,
                                                    bottom: 8.0),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Notes:",
                                                        style:
                                                            GoogleFonts.inter(
                                                          fontSize: 14.0,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 4.0),
                                                      Text(
                                                        item.notes,
                                                        style: const TextStyle(
                                                          fontSize: 13.0,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    provider.updateQty(
                                                        item.cartId,
                                                        item.qty - 1);
                                                  },
                                                  icon: const Icon(
                                                    Icons.remove_rounded,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    provider.updateQty(
                                                        item.cartId,
                                                        item.qty + 1);
                                                  },
                                                  icon: const Icon(
                                                      Icons.add_rounded,
                                                      color: Colors.white),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    provider.removeItem(item);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Column(
                            children: [
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
                                  onPressed: () async {
                                    var mainProvider =
                                        Provider.of<MainProvider>(context,
                                            listen: false);
                                    var irepBE = IrepBE();
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
                                    var request = QrisOrderRequest(
                                        orders: provider.currentOrder,
                                        payment: 'qris',
                                        source: 'cafe');
                                    // QrisOrderResponse response =
                                    //     await irepBE.createOrder(request);
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        useSafeArea: true,
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(16.0),
                                          ),
                                        ),
                                        builder: (context) {
                                          return PaymentDialogBottomSheet(
                                            transaction: transaction,
                                          );
                                        });
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (BuildContext context) {
                                    //     return PaymentDialog(
                                    //       transaction: transaction,
                                    //     );
                                    //   },
                                    // );
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
