import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/services/irepbe_services.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionData> _allTransactions = [];
  List<TransactionData> _filteredTransactions = [];
  TransactionData? _selectedTransaction;
  int _currentPageIndex = 1;
  int _totalPages = 0;

  List<TransactionData> get transactions => _allTransactions;
  List<TransactionData> get filteredTransactions => _filteredTransactions;
  TransactionData? get selectedTransaction => _selectedTransaction;
  int get currentPageIndex => _currentPageIndex;
  int get totalPages => _totalPages;

  TransactionProvider() {
    getAllTransactions(1);
  }

  Future<void> getAllTransactions(int page) async {
    IrepBE irepBE = IrepBE();
    try {
      GetTransacationsResponse response = await irepBE.getTransactions(page);
      if (response.data.isNotEmpty) {
        _allTransactions = response.data;
        _filteredTransactions = response.data;
        _currentPageIndex = page;
        _totalPages = response.totalPages;
        notifyListeners();
      } else {
        print('No transactions found.');
      }
    } catch (e) {
      rethrow;
    }
  }

  // void filterTransactionsByTimeframe(DateTime start, DateTime end) {
  //   _filteredTransactions = _allTransactions
  //       .where((transaction) =>
  //           transaction.transactionDate >= start.millisecondsSinceEpoch &&
  //           transaction.transactionDate <= end.millisecondsSinceEpoch)
  //       .toList();
  //   notifyListeners();
  // }

  // Future<void> addTransaction(TransactionModel transaction) {
  //   try {
  //     return _firebaseService.addTransaction(transaction);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  void selectTransaction(TransactionData transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
}
