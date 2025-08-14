import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/cafe_backend_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuProvider with ChangeNotifier {
  List<MenuIrep> _allMenus = [];
  List<MenuIrep> _filteredMenus = [];
  List<String> _allCategories = [];
  MenuIrep? _selectedMenu;
  String _selectedCategory = "All";
  String _apiUrl = '';

  String get apiUrl => _apiUrl;

  List<MenuIrep> get allmenus => _allMenus;
  List<MenuIrep> get filteredMenus => _filteredMenus;
  List<String> get allCategories => _allCategories;
  MenuIrep? get selectedMenu => _selectedMenu;
  String get selectedCategory => _selectedCategory;

  MenuProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadApiUrl();
  }

  Future<void> _loadApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('apiUrl')) {
      await prefs.setString('apiUrl', 'https://warnet-api.indorep.com');
    } else {
      _apiUrl = prefs.getString('apiUrl') ?? 'https://warnet-api.indorep.com';
    }
    notifyListeners();
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
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      List<MenuIrep> fetchedMenus = await irepBE.getAllMenus();
      // Sort the fetched menus alphabetically by title
      fetchedMenus.sort((a, b) =>
          a.menuName.toLowerCase().compareTo(b.menuName.toLowerCase()));
      _allMenus = fetchedMenus;
      filterMenusByCategory(_selectedCategory);
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
    _filteredMenus = category == 'All'
        ? List.from(_allMenus)
        : _allMenus.where((menu) => menu.menuType == category).toList();

    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners(); // Notify UI of the change
    }
  }

  Future<AddMenuResponse> addMenu(AddMenuRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      AddMenuResponse res = await irepBE.addMenu(request);
      if (res.success) {
        await fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      await fetchAllMenus();
      notifyListeners();
      rethrow;
    }
  }

  Future<EditMenuResponse> editMenu(AddMenuRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      EditMenuResponse res = await irepBE.editMenu(request);
      if (res.success) {
        await fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      await fetchAllMenus();
      rethrow;
    }
  }

  Future<DefaultResponse> deleteMenu(int menuId) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      DefaultResponse res = await irepBE.deleteMenu(menuId);
      if (res.success) {
        await fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      await fetchAllMenus();
      rethrow;
    }
  }

  Future<AddOptionResponse> addOption(AddOptionRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      AddOptionResponse res = await irepBE.addOption(request);
      if (res.success) {
        fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> editOption(EditOptionRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      await irepBE.editOption(request);
      fetchAllMenus();
    } catch (e) {
      fetchAllMenus();
      print(e);
    }
  }

  Future<void> addOptionValue(AddOptionValueRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      await irepBE.addOptionValue(request);
      fetchAllMenus();
    } catch (e) {
      fetchAllMenus();
      print(e);
    }
  }

  Future<void> editOptionValue(EditOptionValueRequest request) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      await irepBE.editOptionValue(request);
      fetchAllMenus();
    } catch (e) {
      fetchAllMenus();
      print(e);
    }
  }

  Future<DefaultResponse> deleteOption(int optionId) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      DefaultResponse res = await irepBE.deleteOption(optionId);
      if (res.success) {
        await fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      await fetchAllMenus();
      rethrow;
    }
  }

  Future<DefaultResponse> deleteOptionValue(int optionValueId) async {
    CafeBackendServices irepBE = CafeBackendServices();
    try {
      DefaultResponse res = await irepBE.deleteOptionValue(optionValueId);
      if (res.success) {
        await fetchAllMenus();
        notifyListeners();
      }
      return res;
    } catch (e) {
      await fetchAllMenus();
      rethrow;
    }
  }
}
