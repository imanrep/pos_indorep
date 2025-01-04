import 'package:flutter/material.dart';
import 'package:pos_indorep/model/example_data.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  List<Menu> _allMenus = [];
  List<Menu> _filteredMenus = [];
  List<Category> _allCategories = [];
  Menu? _selectedMenu;

  List<Menu> get allmenus => _allMenus;
  List<Menu> get filteredMenus => _filteredMenus;
  List<Category> get allCategories => _allCategories;
  Menu? get selectedMenu => _selectedMenu;

  final FirebaseService _firebaseService = FirebaseService();

  MenuProvider() {
    fetchAllCategories();
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

  void clearSelectedMenu() {
    _selectedMenu = null;
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
      List<Category> fetchedCategories =
          await _firebaseService.getAllCategories();
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
      return _allMenus
          .where((menu) => menu.category.categoryId == category)
          .length;
    }
  }

  Future<void> pushExampleMenus() async {
    try {
      await _firebaseService.addCategory('makanan');
      await _firebaseService.addCategory('makanan');
      await _firebaseService.pushExampleData(ExampleData().exampleMenu);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> addMenu(Menu menu) async {
    try {
      await _firebaseService.addMenu(menu);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> deleteMenu(Menu menu) async {
    try {
      await _firebaseService.deleteMenu(menu);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> updateMenu(Menu menu) async {
    try {
      await _firebaseService.updateMenu(menu);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> addCategory(String category) async {
    try {
      await _firebaseService.addCategory(category);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      await _firebaseService.deleteCategory(category);
      fetchAllCategories();
      fetchAllMenus();
    } catch (e) {
      // Handle error
      print(e);
    }
  }
}
