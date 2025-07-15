import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/irepbe_services.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _currentCart = [];
  List<OrderItem> _currentOrder = [];
  double _totalCurrentCart = 0;
  String? _voucher;
  int? _off = 0;

  List<CartItem> get currentCart => _currentCart;
  List<OrderItem> get currentOrder => _currentOrder;
  double get totalCurrentCart => _totalCurrentCart;
  String? get voucher => _voucher;
  int? get off => _off;

  void calculateTotalCart() {
    _totalCurrentCart = 0;
    for (var item in _currentCart) {
      _totalCurrentCart += (item.subTotal);
    }
    notifyListeners();
  }

  void clearCart() {
    _currentCart.clear();
    _currentOrder.clear();
    _totalCurrentCart = 0;
    _voucher = null;
    _off = 0;
    notifyListeners();
  }

  void addItem(CartItem item) {
    _currentCart.add(item);
    _currentOrder.add(
      OrderItem(
        id: item.menuId,
        qty: item.qty,
        note: item.notes,
        option: [
          for (var opt in item.selectedOptions)
            for (var val in opt.optionValue.where((v) => v.isSelected))
              OptionOrderItem(
                optionId: opt.optionId,
                valueId: val.optionValueId,
              ),
        ],
      ),
    );
    calculateTotalCart();
    notifyListeners();
  }

  void setVoucher(String? voucher) {
    _voucher = voucher;
    notifyListeners();
  }

  void setOff(int? off) {
    _off = off;
    notifyListeners();
  }

  Future<void> getVoucherDetails() async {
    var irepBE = IrepBE();
    try {
      final value = await irepBE.getVoucherDetails(_voucher ?? '');
      if (value.success && value.off != 0) {
        _off = value.off;
      } else {
        _off = 0;
      }
      notifyListeners();
    } catch (error) {
      debugPrint('Error fetching voucher details: $error');
      _off = 0;
      _voucher = null;
      notifyListeners();
    }
  }

  void updateQty(String cartId, int qty) {
    final cartItem = _currentCart.firstWhere((item) => item.cartId == cartId);
    if (qty > 0) {
      cartItem.updateQty(qty);
      calculateTotalCart();
      notifyListeners();
    }
  }

  // void toggleSelectedOptionFromCart(
  //     String cartId, int optionId, String option, bool isSelected) {
  //   final cartIndex = _currentCart.indexWhere((item) => item.cartId == cartId);
  //   if (cartIndex != -1) {
  //     final cartItem = _currentCart[cartIndex];

  //     cartItem.selectedOption ??= SelectedOption(
  //         selectedOptionId: optionId,
  //         title: cartItem.option
  //                 .firstWhere(
  //                   (element) => element.optionId == optionId,
  //                 )
  //                 .optionName,
  //         selected: option,
  //       );

  //     List<String> selectedOptions =
  //         List<String>.from(cartItem.selectedOption!.selected ?? []);

  //     if (isSelected) {
  //       // Add if not already present
  //       if (!selectedOptions.contains(option)) {
  //         selectedOptions.add(option);
  //       }
  //     } else {
  //       // Remove if present
  //       selectedOptions.remove(option);
  //     }

  //     cartItem.selectedOption!.selected = selectedOptions;

  //     debugPrint('Updated Cart (${cartItem.cartId}): $selectedOptions');

  //     notifyListeners();
  //   }
  // }

  void addItemNotes(String cartId, String notes) {
    final index =
        _currentCart.indexWhere((element) => element.cartId == cartId);
    _currentCart[index].notes = notes;
    notifyListeners();
  }

  void addItemOption(String cartId, String option) {
    final index =
        _currentCart.indexWhere((element) => element.cartId == cartId);
    _currentCart[index].notes = option;
    notifyListeners();
  }

  void removeItem(MenuIrep item) {
    _currentCart.remove(item);
    _currentOrder.removeWhere((element) => element.id == item.menuId);
    calculateTotalCart();
    notifyListeners();
  }
}
