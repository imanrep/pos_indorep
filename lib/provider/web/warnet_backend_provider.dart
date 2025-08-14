import 'package:flutter/material.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/kulkas_item_response.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/web_model.dart';

class WarnetBackendProvider extends ChangeNotifier {
  AllCustomersResult? _allWarnetCustomers;
  bool _isLoadingEntries = true;
  WarnetPaket _selectedPaket =
      WarnetPaket(nama: 'Paket 1 Jam', harga: 15000, hargaAsli: 15000);
  String _selectedMethod = 'Cash';
  bool _isPaketMalam = false;
  DateTime _selectedSummaryDate = DateTime.now();

  int _jumlahMember = 0;
  int _jumlahItemKulkas = 0;
  int _totalTransaksiWarnet = 0;
  int _totalTransaksiKulkas = 0;
  int _omzetWarnet = 0;
  int _omzetKulkas = 0;

  List<KulkasItem> _kulkasItems = [];

  final List<WarnetPaket> _packages = [
    WarnetPaket(nama: 'Paket 1 Jam', harga: 15000, hargaAsli: 15000),
    WarnetPaket(nama: 'Paket 2 Jam', harga: 30000, hargaAsli: 30000),
    WarnetPaket(nama: 'Paket 3 Jam', harga: 45000, hargaAsli: 45000),
    WarnetPaket(nama: 'Paket Bocah', harga: 50000, hargaAsli: 75000),
    WarnetPaket(nama: 'Paket Levelling', harga: 100000, hargaAsli: 180000),
  ];

  final List<String> _methods = ['Cash', 'QRIS'];

  AllCustomersResult? get allWarnetCustomers => _allWarnetCustomers;
  bool get isLoadingEntries => _isLoadingEntries;
  WarnetPaket get selectedPaket => _selectedPaket;
  String get selectedMethod => _selectedMethod;
  bool get isPaketMalam => _isPaketMalam;
  List<KulkasItem> get kulkasItems => _kulkasItems;
  List<WarnetPaket> get packages => _packages;
  List<String> get methods => _methods;
  DateTime get selectedSummaryDate => _selectedSummaryDate;

  int get jumlahMember => _jumlahMember;
  int get jumlahItemKulkas => _jumlahItemKulkas;
  int get totalTransaksiWarnet => _totalTransaksiWarnet;
  int get totalTransaksiKulkas => _totalTransaksiKulkas;
  int get omzetWarnet => _omzetWarnet;
  int get omzetKulkas => _omzetKulkas;

  WarnetBackendProvider() {
    init();
  }

  Future<void> init() async {
    await getAllCustomerWarnet('');
    await getKulkasItem();
    setJumlahMember(allWarnetCustomers!.members.length);
    setTotalTransaksiWarnet(allWarnetCustomers!.totalTransactions);
  }

  void setSelectedMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void setSelectedPaket(WarnetPaket paket) {
    _selectedPaket = paket;
    notifyListeners();
  }

  void setJumlahMember(int jumlah) {
    _jumlahMember = jumlah;
    notifyListeners();
  }

  void setTotalTransaksiWarnet(int total) {
    _totalTransaksiWarnet = total;
    notifyListeners();
  }

  Future<void> onSummaryDateChanged(DateTime newDate) async {
    _selectedSummaryDate = newDate;
    notifyListeners();
    // await fetchWarnetEntriesByDate(newDate);
  }

  Future<void> getAllCustomerWarnet(String username) async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      _isLoadingEntries = true;
      var result = await services.fetchAllCustomers(username);
      _allWarnetCustomers = result;
      notifyListeners();
      _isLoadingEntries = false;
    } catch (e) {
      _allWarnetCustomers = null;
      _isLoadingEntries = false;
    }
  }

  Future<void> getKulkasItem() async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.getKulkasItem();
      if (result.success) {
        _jumlahItemKulkas = result.message.length;
        _totalTransaksiKulkas = 0;
        _omzetKulkas = 0;
        _kulkasItems = result.message;
        notifyListeners();
      }
    } catch (e) {
      _jumlahItemKulkas = 0;
      _totalTransaksiKulkas = 0;
      _omzetKulkas = 0;
      notifyListeners();
    }
  }
}
