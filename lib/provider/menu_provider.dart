import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/firebase_service.dart';

class MenuProvider with ChangeNotifier {
  List<Menu> _allMenus = [];
  List<Menu> _filteredMenus = [];

  List<Menu> get allmenus => _allMenus;
  List<Menu> get filteredMenus => _filteredMenus;

  final FirebaseService _firebaseService = FirebaseService();

  void filterMenusByCategory(String category) {
    if (category == 'All') {
      _filteredMenus = _allMenus;
    } else {
      _filteredMenus =
          _allMenus.where((menu) => menu.category == category).toList();
    }
    notifyListeners();
  }

  Future<void> fetchAllMenus() async {
    try {
      List<Menu> fetchedMenus = await _firebaseService.getAllMenus();
      _allMenus = fetchedMenus;
      _filteredMenus = fetchedMenus;
      notifyListeners();
    } catch (e) {
      // Handle error
      print(e);
    }
  }
}
