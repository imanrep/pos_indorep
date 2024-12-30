import 'package:flutter/material.dart';
import 'package:pos_indorep/model/example_data.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  List<Menu> _allMenus = [];
  List<Menu> _filteredMenus = [];
  List<String> _allCategories = [];
  Menu? _selectedMenu;

  List<Menu> get allmenus => _allMenus;
  List<Menu> get filteredMenus => _filteredMenus;
  List<String> get allCategories => _allCategories;
  Menu? get selectedMenu => _selectedMenu;

  final FirebaseService _firebaseService = FirebaseService();

  MenuProvider() {
    fetchAllMenus();
  }

  void filterMenusByCategory(String category) {
    if (category == 'All') {
      _filteredMenus = _allMenus;
    } else {
      _filteredMenus =
          _allMenus.where((menu) => menu.category == category).toList();
    }
    notifyListeners();
  }

  void selectMenu(Menu menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  Future<void> fetchAllMenus() async {
    try {
      List<Menu> fetchedMenus = await _firebaseService.getAllMenus();
      _allMenus = fetchedMenus;
      _filteredMenus = fetchedMenus;
      notifyListeners();
      fetchAllCategories();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> fetchAllCategories() async {
    try {
      List<String> fetchedCategories = [];
      for (var menu in _allMenus) {
        if (!fetchedCategories.contains(menu.category)) {
          fetchedCategories.add(menu.category);
        }
      }
      _allCategories = fetchedCategories;
      notifyListeners();
      debugPrint('All Categories: $_allCategories');
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  int getCategoryCount(String category) {
    if (category == 'All') {
      return _allMenus.length;
    } else {
      return _allMenus.where((menu) => menu.category == category).length;
    }
  }

  Future<void> pushExampleMenus() async {
    try {
      await _firebaseService.pushExampleData(ExampleData().exampleMenu);
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }
}
