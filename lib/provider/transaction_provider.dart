import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  TransactionModel? _selectedTransaction;

  List<TransactionModel> get transactions => _allTransactions;
  List<TransactionModel> get filteredTransactions => _filteredTransactions;
  TransactionModel? get selectedTransaction => _selectedTransaction;

  TransactionProvider() {
    // getAllTransactions();
  }

  // Future<void> getAllTransactions() async {
  //   try {
  //     List<TransactionModel> fetchedTransactions =
  //         await _firebaseService.getAllTransaction();
  //     // Sort the fetched transactions by transactionDate in descending order (latest first)
  //     fetchedTransactions
  //         .sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  //     _allTransactions = fetchedTransactions;
  //     notifyListeners();
  //   } catch (e) {
  //     // Handle error
  //     print(e);
  //   }
  // }

  void filterTransactionsByTimeframe(DateTime start, DateTime end) {
    _filteredTransactions = _allTransactions
        .where((transaction) =>
            transaction.transactionDate >= start.millisecondsSinceEpoch &&
            transaction.transactionDate <= end.millisecondsSinceEpoch)
        .toList();
    notifyListeners();
  }

  // Future<void> addTransaction(TransactionModel transaction) {
  //   try {
  //     return _firebaseService.addTransaction(transaction);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  void selectTransaction(TransactionModel transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
}
