import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_indorep/services/web_services.dart';
import 'package:pos_indorep/web/model/web_model.dart';

class WebTransaksiProvider extends ChangeNotifier {
  String _cafeId = '';
  String _authToken = '';
  final WebServices _services = WebServices();
  DateTime _selectedWarnetDate = DateTime.now();
  DateTime _selectedBeveragesDate = DateTime.now();
  String _selectedBeverages = 'Pristine 400ml';

  WarnetPaket _selectedPackage = WarnetPaket(
    nama: 'Paket 1 Jam',
    harga: 15000,
  );
  String _selectedMethod = 'Cash';
  String _selectedOperator = 'Agung';

  List<IndorepWarnetModel> _currentWarnetEntries = [];
  List<IndorepBeveragesModel> _currentBeveragesEntries = [];

  bool _isLoadingEntries = true;
  bool _isLoadingBeverages = true;
  bool _isLoadingPCs = true;

  final List<String> _operators = ['Agung', 'Asep', 'Fajar', 'Gume'];
  final List<WarnetPaket> _packages = [
    WarnetPaket(nama: 'Paket 1 Jam', harga: 15000),
    WarnetPaket(nama: 'Paket 2 Jam', harga: 30000),
    WarnetPaket(nama: 'Paket 3 Jam', harga: 45000),
    WarnetPaket(nama: 'Paket Bocah', harga: 50000),
    WarnetPaket(nama: 'Paket Levelling', harga: 100000),
    WarnetPaket(nama: 'Paket Malam', harga: 50000),
  ];

  final List<Beverages> _beverages = [
    Beverages(nama: 'Pristine 400ml', harga: 5000),
    Beverages(nama: 'Pristine 600ml', harga: 7000),
    Beverages(nama: 'Coca-Cola 390ml', harga: 6000),
    Beverages(nama: 'Teh Pucuk', harga: 5000),
    Beverages(nama: 'Sprite Water', harga: 6000),
    Beverages(nama: 'Better', harga: 2000),
    Beverages(nama: 'Beng-beng', harga: 3000),
  ];

  final List<String> _methods = ['Cash', 'QRIS'];

  String get cafeId => _cafeId;
  String get authToken => _authToken;

  DateTime get selectedWarnetDate => _selectedWarnetDate;
  DateTime get selectedBeveragesDate => _selectedBeveragesDate;
  String get selectedBeverages => _selectedBeverages;
  WarnetPaket get selectedPackage => _selectedPackage;
  String get selectedMethod => _selectedMethod;
  String get selectedOperator => _selectedOperator;
  List<IndorepWarnetModel> get currentWarnetEntries => _currentWarnetEntries;
  List<IndorepBeveragesModel> get currentBeveragesEntries =>
      _currentBeveragesEntries;

  bool get isLoadingEntries => _isLoadingEntries;
  bool get isLoadingBeverages => _isLoadingBeverages;
  bool get isLoadingPCs => _isLoadingPCs;

  List<String> get operators => _operators;
  List<WarnetPaket> get packages => _packages;
  List<Beverages> get beverages => _beverages;
  List<String> get methods => _methods;

  WebTransaksiProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchCurrentOperator();
    await fetchWarnetEntriesByDate(_selectedWarnetDate);
    await fetchBeveragesEntriesByDate(_selectedBeveragesDate);
  }

  void setSelectedWarnetDate(DateTime date) {
    _selectedWarnetDate = date;
    notifyListeners();
  }

  void setSelectedBeveragesDate(DateTime date) {
    _selectedBeveragesDate = date;
    notifyListeners();
  }

  void setSelectedBeverages(String beverages) {
    _selectedBeverages = beverages;
    notifyListeners();
  }

  void setSelectedPackage(WarnetPaket paket) {
    _selectedPackage = paket;
    notifyListeners();
  }

  void setSSelectedMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<void> fetchCurrentOperator() async {
    final currentOperator = await _services.getCurrentOperator();
    _selectedOperator = currentOperator ?? _operators.first;
    notifyListeners();
  }

  Future<void> fetchBeveragesEntriesByDate(DateTime date) async {
    _isLoadingBeverages = true;
    notifyListeners();
    final snapshot = await _services.getBeveragesByDate(date).first;
    List<IndorepBeveragesModel> data = snapshot.docs
        .map((doc) =>
            IndorepBeveragesModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    _currentBeveragesEntries = data;
    _isLoadingBeverages = false;
    notifyListeners();
  }

  Future<void> fetchWarnetEntriesByDate(DateTime date) async {
    _isLoadingEntries = true;
    notifyListeners();
    final snapshot = await _services.getWarnetEntriesByDate(date).first;

    List<IndorepWarnetModel> data = snapshot.docs
        .map((doc) =>
            IndorepWarnetModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
    _currentWarnetEntries = data;
    _isLoadingEntries = false;
    notifyListeners();
  }

  Future<void> onWarnetDateChanged(DateTime newDate) async {
    _selectedWarnetDate = newDate;
    notifyListeners();
    await fetchWarnetEntriesByDate(newDate);
  }

  Future<void> onBeveragesDateChanged(DateTime newDate) async {
    _selectedBeveragesDate = newDate;
    notifyListeners();
    fetchBeveragesEntriesByDate(newDate);
  }

  Future<void> submitCashierEntry(String username) async {
    _services
        .addCashierEntry(
      entry: IndorepWarnetModel(
        timestamp: Timestamp.now(),
        username: username,
        paket: _selectedPackage,
        metode: _selectedMethod,
        operator: _selectedOperator,
      ),
    )
        .then((_) {
      fetchWarnetEntriesByDate(DateTime.now());
      _selectedWarnetDate = DateTime.now();
      notifyListeners();
    });
  }

  Future<void> submitBeveragesEntry(String qty) async {
    _services
        .addBeveragesEntry(
            entry: IndorepBeveragesModel(
      timestamp: Timestamp.now(),
      beverages: Beverages(
        nama: _selectedBeverages,
        harga: _beverages.firstWhere((b) => b.nama == _selectedBeverages).harga,
      ),
      qty: int.parse(qty),
      grandTotal: int.parse(qty) *
          _beverages.firstWhere((b) => b.nama == _selectedBeverages).harga,
      metode: _selectedMethod,
      operator: _selectedOperator,
    ))
        .then((_) {
      fetchBeveragesEntriesByDate(DateTime.now());
      _selectedBeveragesDate = DateTime.now();
    });
  }
}
