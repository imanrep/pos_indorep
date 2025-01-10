import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/firebase_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  TransactionModel? _selectedTransaction;

  List<TransactionModel> get transactions => _transactions;
  TransactionModel? get selectedTransaction => _selectedTransaction;

  final FirebaseService _firebaseService = FirebaseService();

  TransactionProvider() {
    getAllTransactions();
  }

  Future<void> getAllTransactions() async {
    try {
      List<TransactionModel> fetchedTransactions =
          await _firebaseService.getAllTransaction();
      _transactions = fetchedTransactions;
      notifyListeners();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) {
    try {
      return _firebaseService.addTransaction(transaction);
    } catch (e) {
      rethrow;
    }
  }

  void selectTransaction(TransactionModel transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
}
