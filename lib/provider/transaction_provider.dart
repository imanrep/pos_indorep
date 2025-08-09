import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/screen/transaction/transaction_page.dart';
import 'package:pos_indorep/services/irepbe_services.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionData> _allTransactions = [];
  List<TransactionData> _filteredTransactions = [];
  TransactionData? _selectedTransaction;
  int _currentPageIndex = 1;
  int _totalPages = 0;
  FilterType _filterSource = FilterType.all;
  Set<String> _newOrderIds = {};

  Timer? _refreshTimer;

  // Firestore reference
  final String userId = 'INDOREP-POS';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<TransactionData> get allTransactions => _allTransactions;
  List<TransactionData> get filteredTransactions => _filteredTransactions;
  TransactionData? get selectedTransaction => _selectedTransaction;
  int get currentPageIndex => _currentPageIndex;
  int get totalPages => _totalPages;
  FilterType get filterSource => _filterSource;
  Set<String> get newOrderIds => _newOrderIds;

  // Red dot if any visible transaction is in newOrderIds
  bool get hasNewData =>
      _filteredTransactions.any((tx) => _newOrderIds.contains(tx.orderId));

  TransactionProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadNewOrderIds();
    await getAllTransactions(1);
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        getAllTransactions(_currentPageIndex);
        _loadNewOrderIds(); // Keep in sync with Firestore
      },
    );
  }

  Future<void> _loadNewOrderIds() async {
    final doc = await firestore.collection('users').doc(userId).get();
    final ids = doc.data()?['newOrderIds'] as List<dynamic>? ?? [];
    _newOrderIds = ids.map((e) => e.toString()).toSet();
    notifyListeners();
  }

  Future<void> _saveNewOrderIds() async {
    await firestore.collection('users').doc(userId).set({
      'newOrderIds': _newOrderIds.toList(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
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

  // Call this when a transaction is tapped/seen
  Future<void> markOrderIdAsSeen(String orderId) async {
    if (_newOrderIds.contains(orderId)) {
      _newOrderIds.remove(orderId);
      await _saveNewOrderIds();
      notifyListeners();
    }
  }

  void filterTransactionsByType(FilterType type) {
    _filterSource = type;
    if (type == FilterType.all) {
      _filteredTransactions = _allTransactions;
    } else if (type == FilterType.cafe) {
      _filteredTransactions = _allTransactions
          .where((transaction) =>
              transaction.pc == null || transaction.pc!.isEmpty)
          .toList();
    } else if (type == FilterType.warnet) {
      _filteredTransactions = _allTransactions
          .where((transaction) =>
              transaction.pc != null && transaction.pc!.isNotEmpty)
          .toList();
    }
    notifyListeners();
  }

  void selectTransaction(TransactionData transaction) {
    _selectedTransaction = transaction;
    notifyListeners();
  }

  void clearSelectedTransaction() {
    _selectedTransaction = null;
    notifyListeners();
  }
}
