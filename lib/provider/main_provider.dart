import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:uuid/uuid.dart';

class MainProvider with ChangeNotifier {
  List<Cart> _currentCart = [];

  List<Cart> get currentCart => _currentCart;

  void addItem(Menu item, int qty, String notes) {
    var uuid = Uuid();

    _currentCart.add(Cart(
      cartId: uuid.v4(),
      menuId: item.menuId,
      title: item.title,
      category: item.category,
      tag: item.tag,
      image: item.image,
      desc: item.desc,
      price: item.price,
      option: item.option,
      qty: qty,
      notes: notes,
    ));
    notifyListeners();
  }

  void incrementQty(String cartId) {
    final cartItem = _currentCart.firstWhere((item) => item.cartId == cartId);
    cartItem.updateQty(cartItem.qty + 1);
    notifyListeners();
  }

  void decrementQty(String cartId) {
    final cartItem = _currentCart.firstWhere((item) => item.cartId == cartId);
    if (cartItem.qty > 1) {
      cartItem.updateQty(cartItem.qty - 1);
      notifyListeners();
    }
  }

  void setSelectedOptionFromCart(
      String cartId, String optionId, String option) {
    final cartIndex = _currentCart.indexWhere((item) => item.cartId == cartId);
    if (cartIndex != -1) {
      final cartItem = _currentCart[cartIndex];
      final optionIndex = cartItem.option
          ?.indexWhere((element) => element.optionId == optionId);
      if (optionIndex != null && optionIndex != -1) {
        cartItem.selectedOption = SelectedOption(
          selectedOptionId: optionId,
          title: cartItem.option![optionIndex].title,
          selected: option,
        );
        debugPrint('Selected Option for ${cartItem.cartId} : $option');
        notifyListeners();
      }
    }
  }

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

  void removeItem(Menu item) {
    _currentCart.remove(item);
    notifyListeners();
  }
}
