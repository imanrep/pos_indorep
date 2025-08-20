import 'package:flutter/material.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/kulkas_item_response.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/web_model.dart';

class WarnetTransaksiProvider extends ChangeNotifier {
  AllCustomersResult? _allWarnetCustomers;
  bool _isLoadingEntries = true;
  WarnetPaket _selectedPaket =
      WarnetPaket(nama: 'Paket 1 Jam', harga: 15000, hargaAsli: 15000);
  String _selectedMethod = 'Cash';
  bool _isPaketMalam = false;
 

  List<KulkasItem> _kulkasItems = [];

  final List<WarnetPaket> _packages = [
    WarnetPaket(nama: 'Paket Dev Testing', harga: 100, hargaAsli: 100),
    WarnetPaket(nama: 'Paket 1 Jam', harga: 15000, hargaAsli: 15000),
    WarnetPaket(nama: 'Paket 2 Jam', harga: 30000, hargaAsli: 30000),
    WarnetPaket(nama: 'PaMer 5 Jam', harga: 44999, hargaAsli: 75000),
    WarnetPaket(nama: 'Paket 3 Jam', harga: 45000, hargaAsli: 45000),
    WarnetPaket(nama: 'Paket Bocah', harga: 50000, hargaAsli: 75000),
     WarnetPaket(nama: 'PaMer 12 Jam', harga: 80000, hargaAsli: 180000),
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


  WarnetTransaksiProvider() {
    init();
  }

  Future<void> init() async {
    _isLoadingEntries = true;
    await getAllCustomerWarnet('');
    await getKulkasItem();
    _isLoadingEntries = false;
    notifyListeners();
  }

  void setSelectedMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }

  void setSelectedPaket(WarnetPaket paket) {
    _selectedPaket = paket;
    notifyListeners();
  }


  Future<void> getAllCustomerWarnet(String username) async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.fetchAllCustomers(username);
      _allWarnetCustomers = result;
      notifyListeners();
    } catch (e) {
      _allWarnetCustomers = null;
    }
  }

  Future<void> getKulkasItem() async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.getKulkasItem();
      if (result.success) {
        _kulkasItems = result.message;
        notifyListeners();
      }
    } catch (e) {
      notifyListeners();
    }
  }


}
