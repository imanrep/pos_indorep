import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/services/warnet_backend_services.dart';
import 'package:pos_indorep/web/model/get_food_info_response.dart';
import 'package:pos_indorep/web/model/get_sales_summary_warnet.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';

class WarnetDashboardProvider extends ChangeNotifier {
  DateTime _selectedSummaryDate = DateTime.now();

  int _jumlahMember = 0;
  int _jumlahItemKulkas = 0;
  int _totalTransaksiKulkas = 0;
  int _omzetKulkas = 0;
  int _totalPCAvailable = 0;
  int _totalPCOnline = 0;
  List<GetFoodInfoResponse> _foodOrders = [];
  AllCustomersResult? _allWarnetCustomers;
  GetSalesSummaryWarnet? _allTimeSalesSummaryWarnet;
  GetSalesSummaryWarnet? _dailySalesSummaryWarnet;

  bool _isFoodOrdersLoading = true;
  bool _isSummaryItemLoading = true;

  List<Pc> _pcs = [];

  DateTime get selectedSummaryDate => _selectedSummaryDate;
  int get jumlahMember => _jumlahMember;
  int get jumlahItemKulkas => _jumlahItemKulkas;
  int get totalTransaksiKulkas => _totalTransaksiKulkas;
  int get omzetKulkas => _omzetKulkas;
  int get totalPCAvailable => _totalPCAvailable;
  int get totalPCOnline => _totalPCOnline;
  List<Pc> get pcs => _pcs;
  int get totalPC => _pcs.length;
  List<GetFoodInfoResponse> get foodOrders => _foodOrders;
  AllCustomersResult? get allWarnetCustomers => _allWarnetCustomers;
  GetSalesSummaryWarnet? get allTimeSalesSummaryWarnet =>
      _allTimeSalesSummaryWarnet;
  GetSalesSummaryWarnet? get dailySalesSummaryWarnet =>
      _dailySalesSummaryWarnet;

  bool get isFoodOrdersLoading => _isFoodOrdersLoading;
  bool get isSummaryItemLoading => _isSummaryItemLoading;

  WarnetDashboardProvider() {
    init();
  }

  Future<void> init() async {
    WarnetBackendServices services = WarnetBackendServices();
    try {
      _allWarnetCustomers = await services.fetchAllCustomers('');
      await getKulkasItem();
      await getPCOnline();
      await getTotalPCAvailable();
      await getFoodInfo();
      _jumlahMember = _allWarnetCustomers?.members.length ?? 0;
      await _fetchDailySummary();
      notifyListeners();
    } catch (e) {
      _allWarnetCustomers = null;
      _jumlahMember = 0;
      _jumlahItemKulkas = 0;
      _totalTransaksiKulkas = 0;
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

  void setLoading(bool isLoading) {
    _isSummaryItemLoading = isLoading;
    _isFoodOrdersLoading = isLoading;
    notifyListeners();
  }

  Future<void> onSummaryDateChanged(DateTime newDate) async {
    WarnetBackendServices services = WarnetBackendServices();
    String formattedDate = DateFormat('dd-MM-yyyy').format(newDate);

    _selectedSummaryDate = newDate;
    GetSalesSummaryWarnet? response = await services.getSalesSummaryWarnet(
        null, formattedDate, formattedDate);
    _dailySalesSummaryWarnet = response;
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

  Future<void> getTotalPCAvailable() async {
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

  Future<void> getPCOnline() async {
    var count = 0;
    allWarnetCustomers?.members.forEach((member) {
      if (member.memberIsLogined == 1) {
        count++;
      }
    });
    _totalPCOnline = count;
    notifyListeners();
  }

  Future<void> getFoodInfo() async {
    notifyListeners();
    WarnetBackendServices services = WarnetBackendServices();
    try {
      var result = await services.getFoodInfo();
      if (result.isNotEmpty) {
        _foodOrders = result;
        _isFoodOrdersLoading = false;
        notifyListeners();
      } else {
        _foodOrders = [];
        _isFoodOrdersLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _foodOrders = [];
      _isFoodOrdersLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchDailySummary() async {
    var services = WarnetBackendServices();
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(_selectedSummaryDate);

    GetSalesSummaryWarnet allSummaryResponse =
        await services.getSalesSummaryWarnet('all', null, null);
    GetSalesSummaryWarnet? dailySummaryResponse = await services
        .getSalesSummaryWarnet(null, formattedDate, formattedDate);
    _allTimeSalesSummaryWarnet = allSummaryResponse;
    _dailySalesSummaryWarnet = dailySummaryResponse;
    _isSummaryItemLoading = false;
    notifyListeners();
  }
}
