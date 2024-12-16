import 'package:flutter/material.dart';
import 'package:pos_indorep/model/menu.dart';

class MainProvider with ChangeNotifier {
  List<Menu> _selectedItems = [];

  List<Menu> get selectedItems => _selectedItems;

  void addItem(Menu item) {
    _selectedItems.add(item);
    notifyListeners();
  }

  void removeItem(Menu item) {
    _selectedItems.remove(item);
    notifyListeners();
  }
}
