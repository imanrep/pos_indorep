import 'package:flutter/material.dart';
import 'package:pos_indorep/services/web_services.dart';

class WebMainProvider extends ChangeNotifier {
  String _currentOperator = 'Agung';
  final List<String> _operators = ['Agung', 'Asep', 'Fajar', 'Gume'];

  String get currentOperator => _currentOperator;
  List<String> get operators => _operators;

  WebMainProvider() {
    getCurrentOperator();
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
