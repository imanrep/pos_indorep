import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/summary.dart';
import 'package:pos_indorep/services/cafe_backend_services.dart';

class DashboardProvider extends ChangeNotifier {
  bool _isLoading = false;
  SummaryResponse? _filteredSummary;
  SummaryResponse? _dailySummary;
  SummaryResponse? _activeOrderSummary;
  String? _activeSummaryType = '';
  DateTime _selectedDate = DateTime.now();
  bool _isRangeDatePicker = false;
  String _selectedSummaryType = 'all';
  String _totalTransactionsPerformance = '0';
  String _totalItemsPerformance = '0';
  String _totalOmzetPerformance = '0';
  DateTimeRange _selectedRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  bool get isLoading => _isLoading;
  SummaryResponse? get filteredSummary => _filteredSummary;
  SummaryResponse? get dailySummary => _dailySummary;
  SummaryResponse? get activeOrderSummary => _activeOrderSummary;
  String? get activeSummaryType => _activeSummaryType;
  DateTime get selectedDate => _selectedDate;
  bool get isRangeDatePicker => _isRangeDatePicker;
  String get selectedSummaryType => _selectedSummaryType;
  String get totalTransactionsPerformance => _totalTransactionsPerformance;
  String get totalItemsPerformance => _totalItemsPerformance;
  String get totalOmzetPerformance => _totalOmzetPerformance;
  DateTimeRange get selectedRange => _selectedRange;

  DashboardProvider() {
    _fetchDailySummary();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void setFilteredSummary(SummaryResponse? summary) {
    _filteredSummary = summary;
    notifyListeners();
  }

  void setActiveOrderSummary(SummaryResponse? summary) {
    _activeOrderSummary = summary;
    notifyListeners();
  }

  void setActiveSummaryType(String? type) {
    _activeSummaryType = type;
    notifyListeners();
  }

  void setSelectedSummaryType(String type) {
    _selectedSummaryType = type;
    notifyListeners();
  }

  void setIsRangeDatePicker(bool isRange) {
    _isRangeDatePicker = isRange;
    notifyListeners();
  }

  void setSelectedRange(DateTimeRange range) {
    _selectedRange = range;
    notifyListeners();
  }

  Future<String> comparePerformance(DateTime currentDate, String type) async {
    var irepBE = CafeBackendServices();

    String dateTimeFormat(DateTime) {
      return DateFormat('dd-MM-yyyy').format(DateTime);
    }

    var todayDateTimeString = dateTimeFormat(currentDate);
    var yesterdayDateTimeString =
        dateTimeFormat(currentDate.subtract(Duration(days: 1)));

    SummaryResponse? today =
        await irepBE.getSummary(null, todayDateTimeString, todayDateTimeString);

    SummaryResponse? yesterday = await irepBE.getSummary(
        null, yesterdayDateTimeString, yesterdayDateTimeString);

    if (type == 'transaksi') {
      var todayTotalOrders = today.summary.totalOrders;
      var yesterdayTotalOrders = yesterday.summary.totalOrders;
      var substract = todayTotalOrders - yesterdayTotalOrders;
      return substract.toString();
    }
    if (type == 'item') {
      var todayTotalItems = today.summary.totalItems;
      var yesterdayTotalItems = yesterday.summary.totalItems;
      var substract = todayTotalItems - yesterdayTotalItems;
      return substract.toString();
    }

    if (type == 'omzet') {
      var todayTotalIncome = today.summary.totalIncome;
      var yesterdayTotalIncome = yesterday.summary.totalIncome;
      var substract = todayTotalIncome - yesterdayTotalIncome;
      return Helper.rupiahFormatter(substract.toDouble());
    }
    return '0';
  }

  Future<void> _fetchDailySummary() async {
    var irepBE = CafeBackendServices();
    SummaryResponse allSummaryResponse =
        await irepBE.getSummary('all', null, null);
    SummaryResponse? filteredSummaryResponse =
        await irepBE.getSummary('daily', null, null);
    String totalTransactionsPerformanceResponse =
        await comparePerformance(DateTime.now(), 'transaksi');
    String totalItemsPerformanceResponse =
        await comparePerformance(DateTime.now(), 'item');
    String totalOmzetPerformanceResponse =
        await comparePerformance(DateTime.now(), 'omzet');

    _filteredSummary = allSummaryResponse;
    _dailySummary = filteredSummaryResponse;
    _totalTransactionsPerformance = totalTransactionsPerformanceResponse;
    _totalItemsPerformance = totalItemsPerformanceResponse;
    _totalOmzetPerformance = totalOmzetPerformanceResponse;
    notifyListeners();
  }

  Future<void> setSelectedDateAndFetchSummary(DateTime newDate) async {
    _isLoading = true;
    notifyListeners();
    _selectedDate = newDate;
    String formattedDate = DateFormat('dd-MM-yyyy').format(newDate);
    var irepBE = CafeBackendServices();
    SummaryResponse? summary =
        await irepBE.getSummary(null, formattedDate, formattedDate);

    _totalTransactionsPerformance =
        await comparePerformance(newDate, 'transaksi');
    _totalItemsPerformance = await comparePerformance(newDate, 'item');
    _totalOmzetPerformance = await comparePerformance(newDate, 'omzet');

    _dailySummary = summary;
    _isLoading = false;
    notifyListeners();
  }
}
