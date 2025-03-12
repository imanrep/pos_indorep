import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/cart_provider.dart';
import 'package:pos_indorep/screen/pesanan_page/components/widget/option_selection_widget.dart';
import 'package:pos_indorep/screen/pesanan_page/components/widget/quantity_selector_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddItemDialog extends StatefulWidget {
  final MenuIrep selectedMenu;

  const AddItemDialog({
    super.key,
    required this.selectedMenu,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  late List<OptionMenuIrep> localOptions;
  int qty = 1;
  double addOnPrice = 0;
  String notes = '';

  @override
  void initState() {
    super.initState();
    // Create a deep copy of options to avoid modifying the original data
    localOptions = widget.selectedMenu.option!
        .map((option) => OptionMenuIrep(
              available: option.available,
              optionId: option.optionId,
              optionName: option.optionName,
              optionType: option.optionType,
              optionValue: option.optionValue
                  .map((optVal) => OptionValue(
                        optionValueName: optVal.optionValueName,
                        optionValueId: optVal.optionValueId,
                        optionValuePrice: optVal.optionValuePrice,
                        isSelected: false, // Reset selection
                      ))
                  .toList(),
            ))
        .toList();
  }

  void _handleOptionChanged(OptionMenuIrep updatedOption) {
    setState(() {
      int index = localOptions
          .indexWhere((opt) => opt.optionId == updatedOption.optionId);
      if (index != -1) {
        localOptions[index] = updatedOption;
      }
      _calculateTotalPrice();
    });
  }

  void _calculateTotalPrice() {
    setState(() {
      addOnPrice = localOptions
          .expand((option) => option.optionValue)
          .where((optVal) => optVal.isSelected)
          .fold(0, (sum, optVal) => sum + optVal.optionValuePrice);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return AlertDialog(
      title: Text('Tambah Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(widget.selectedMenu.menuImage),
                  onBackgroundImageError: (_, __) {},
                  radius: 70,
                  child: Image.asset('assets/images/default-menu.png'),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.selectedMenu.menuName),
                    Text(widget.selectedMenu.menuNote),
                    const SizedBox(height: 8),
                    QuantitySelectorWidget(onQtyChanged: (newQty) {
                      setState(() {
                        qty = newQty;
                        _calculateTotalPrice();
                      });
                    })
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            ...localOptions.map((option) {
              return OptionSelectionWidget(
                option: option,
                onOptionChanged: _handleOptionChanged,
              );
            }),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  notes = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        Row(
          children: [
            Text(
              Helper.rupiahFormatter(
                  ((widget.selectedMenu.menuPrice + addOnPrice) * qty)
                      .toDouble()),
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                var uuid = Uuid();

                CartItem cartItem = CartItem(
                  cartId: uuid.v4(),
                  createdAt: DateTime.now().millisecondsSinceEpoch,
                  available: widget.selectedMenu.available,
                  menuId: widget.selectedMenu.menuId,
                  title: widget.selectedMenu.menuName,
                  category: widget.selectedMenu.menuType,
                  image: widget.selectedMenu.menuImage,
                  desc: widget.selectedMenu.menuNote,
                  price: widget.selectedMenu.menuPrice.toDouble(),
                  qty: qty,
                  notes: notes,
                  selectedOptions:
                      widget.selectedMenu.option!, // Pass selected options
                );

                cartProvider.addItem(cartItem);
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            )
          ],
        )
      ],
    );
  }
}
