import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/irepbe_services.dart';

class MenuProvider with ChangeNotifier {
  List<MenuIrep> _allMenus = [];
  List<MenuIrep> _filteredMenus = [];
  List<String> _allCategories = [];
  MenuIrep? _selectedMenu;

  List<MenuIrep> get allmenus => _allMenus;
  List<MenuIrep> get filteredMenus => _filteredMenus;
  List<String> get allCategories => _allCategories;
  MenuIrep? get selectedMenu => _selectedMenu;

  MenuProvider() {
    fetchAllMenus();
  }

  void selectMenu(MenuIrep menu) {
    _selectedMenu = menu;
    notifyListeners();
  }

  void clearSelectedMenu() {
    _selectedMenu = null;
    notifyListeners();
  }

  Future<void> fetchAllMenus() async {
    IrepBE irepBE = IrepBE();
    try {
      List<MenuIrep> fetchedMenus = await irepBE.getAllMenus();
      // Sort the fetched menus alphabetically by title
      fetchedMenus.sort((a, b) =>
          a.menuName.toLowerCase().compareTo(b.menuName.toLowerCase()));
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
      List<String> fetchedCategories =
          _allMenus.map((menu) => menu.menuType).toSet().toList();
      _allCategories = fetchedCategories;
      notifyListeners();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  int getCategoryCount(String category) {
    if (category == 'All') {
      return _allMenus.length;
    } else {
      return _allMenus.where((menu) => menu.menuType == category).length;
    }
  }

  void filterMenusByCategory(String category) {
    if (category == 'All') {
      _filteredMenus = _allMenus;
    } else {
      _filteredMenus =
          _allMenus.where((menu) => menu.menuType == category).toList();
    }
    notifyListeners();
  }
}
