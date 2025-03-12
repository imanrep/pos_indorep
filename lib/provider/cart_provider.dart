import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:uuid/uuid.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _currentCart = [];
  double _totalCurrentCart = 0;

  List<CartItem> get currentCart => _currentCart;
  double get totalCurrentCart => _totalCurrentCart;

  void calculateTotalCart() {
    _totalCurrentCart = 0;
    for (var item in _currentCart) {
      _totalCurrentCart += item.subTotal;
    }
    notifyListeners();
  }

  void addItem(CartItem item) {
    var uuid = Uuid();

    _currentCart.add(item);
    calculateTotalCart();
    notifyListeners();
  }

  void incrementQty(String cartId) {
    final cartItem = _currentCart.firstWhere((item) => item.cartId == cartId);
    cartItem.updateQty(cartItem.qty + 1);
    calculateTotalCart();
    notifyListeners();
  }

  void decrementQty(String cartId) {
    final cartItem = _currentCart.firstWhere((item) => item.cartId == cartId);
    if (cartItem.qty > 1) {
      cartItem.updateQty(cartItem.qty - 1);
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
    notifyListeners();
  }
}
