import 'package:flutter/material.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/services/web_services.dart';

class WebMainProvider extends ChangeNotifier {
  String _currentOperator = 'Agung';
  bool _serverOnline = false;
  final List<String> _operators = ['Agung', 'Asep', 'Fajar', 'Gume'];

  String get currentOperator => _currentOperator;
  bool get serverOnline => _serverOnline;
  List<String> get operators => _operators;

  WebMainProvider() {
    _initialize();
    getCurrentOperator();
  }

  Future<void> _initialize() async {
    WarnetBackendServices services = WarnetBackendServices();
    _serverOnline = await services.checkApiStatus('cafeId', 'authToken');
    notifyListeners();
  }

  Future<void> setCurrentOperator(String operator) async {
    _currentOperator = operator;
    notifyListeners();
    WebServices services = WebServices();
    await services.setCurrentOperator(operator);
  }

  Future<void> getCurrentOperator() async {
    WebServices services = WebServices();
    String? operator = await services.getCurrentOperator();
    if (operator != null) {
      _currentOperator = operator;
      notifyListeners();
    }
  }

  // Future<void> fetchOperators() async {
  //   WebServices services = WebServices();
  //   _operators.clear();
  //   _operators.addAll(await services.getOperators());
  //   notifyListeners();
  // }
}
