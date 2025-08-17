import 'package:flutter/material.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/get_food_info_response.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';

class WarnetDashboardProvider extends ChangeNotifier {
 DateTime _selectedSummaryDate = DateTime.now();

  int _jumlahMember = 0;
  int _jumlahItemKulkas = 0;
  int _totalTransaksiWarnet = 0;
  int _totalTransaksiKulkas = 0;
  int _omzetWarnet = 0;
  int _omzetKulkas = 0;
  int _totalPCAvailable = 0;
  int _totalPCOnline = 0;
  List<GetFoodInfoResponse> _foodOrders = [];
  AllCustomersResult? _allWarnetCustomers;

  List<Pc> _pcs = [];
  

  DateTime get selectedSummaryDate => _selectedSummaryDate;
  int get jumlahMember => _jumlahMember;
  int get jumlahItemKulkas => _jumlahItemKulkas;
  int get totalTransaksiWarnet => _totalTransaksiWarnet;
  int get totalTransaksiKulkas => _totalTransaksiKulkas;
  int get omzetWarnet => _omzetWarnet;
  int get omzetKulkas => _omzetKulkas;
  int get totalPCAvailable => _totalPCAvailable;
  int get totalPCOnline => _totalPCOnline;
  List<Pc> get pcs => _pcs;
    int get totalPC => _pcs.length;
  List<GetFoodInfoResponse> get foodOrders => _foodOrders;
  AllCustomersResult? get allWarnetCustomers => _allWarnetCustomers;


  WarnetDashboardProvider() {
    init();
  }

  Future<void>init() async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      _allWarnetCustomers = await services.fetchAllCustomers('');
      await getKulkasItem();
      await getPCOnline();
      await getTotalPCAvailable();
      await getFoodInfo();
      _jumlahMember = _allWarnetCustomers?.members.length ?? 0;
      notifyListeners();
    } catch (e) {
      _allWarnetCustomers = null;
      _jumlahMember = 0;
      _jumlahItemKulkas = 0;
      _totalTransaksiWarnet = 0;
      _totalTransaksiKulkas = 0;
      _omzetWarnet = 0;
      _omzetKulkas = 0;
      _totalPCAvailable = 0;
      _totalPCOnline = 0;
      notifyListeners();
    }
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

  
  Future<void> getKulkasItem() async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.getKulkasItem();
      if (result.success) {
        _jumlahItemKulkas = result.message.length;
        _totalTransaksiKulkas = 0;
        _omzetKulkas = 0;
        // _kulkasItems = result.message;
        notifyListeners();
      }
    } catch (e) {
      _jumlahItemKulkas = 0;
      _totalTransaksiKulkas = 0;
      _omzetKulkas = 0;
      notifyListeners();
    }
  }

  Future<void> getTotalPCAvailable() async{
    WarnetBackendServices services = WarnetBackendServices();
    var res = await services.getPCs();
    _totalPCAvailable = res.data.pcsInit.pcList.length - _totalPCOnline;
    _pcs = res.data.pcsInit.pcList;
    notifyListeners();
  }

  
  Future<void> getAllCustomerWarnet(String username) async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.fetchAllCustomers(username);
      _allWarnetCustomers = result;
      _jumlahMember = result.members.length;
      notifyListeners();
    } catch (e) {
      _jumlahMember = 0;
      _allWarnetCustomers = null;
      notifyListeners();
    }
  }

  Future<void> getPCOnline() async{
    var count = 0;
   allWarnetCustomers?.members.forEach((member) {
      if (member.memberIsLogined == 1) {
        count++;
      }
    });
    _totalPCOnline = count;
    notifyListeners();
  }

  Future<void>getFoodInfo() async {
    WarnetBackendServices services = WarnetBackendServices();
      try{
          
          var result = await services.getFoodInfo();
          if (result.isNotEmpty) {
            _foodOrders = result;
            notifyListeners();
          } else {
            _foodOrders = [];
            notifyListeners();
          }
        } catch (e) {
          _foodOrders = [];
          notifyListeners();
      }
    }
  }