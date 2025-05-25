import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  String _apiUrl = '';
  String _mainRepo = '';
  String _appVersion = '';
  String _printerAddress = '';
  String _printerName = '';

  String get apiUrl => _apiUrl;
  String get mainRepo => _mainRepo;
  String get appVersion => _appVersion;
  String get printerAddress => _printerAddress;
  String get printerName => _printerName;

  MainProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadApiUrl();
    await _loadPrinterAddress();
    await _loadPrinterName();
    loadAppVersion();
  }

  Future<void> _loadApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('apiUrl')) {
      await prefs.setString('apiUrl', 'https://warnet-api.indorep.com');
    } else {
      _apiUrl = prefs.getString('apiUrl') ?? 'https://warnet-api.indorep.com';
    }
    notifyListeners();
  }

  Future<void> _loadPrinterAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('printerAddress')) {
      await prefs.setString('printerAddress', '66:32:3D:2C:E0:EC');
    } else {
      _printerAddress =
          prefs.getString('printerAddress') ?? '66:32:3D:2C:E0:EC';
    }
    notifyListeners();
  }

  Future<void> _loadPrinterName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('printerName')) {
      await prefs.setString('printerName', 'Bluetooth Printer');
    } else {
      _printerName = prefs.getString('printerName') ?? 'No printer selected';
    }
    notifyListeners();
  }

  void loadAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    _appVersion = version;
    notifyListeners();
  }

  void setApiUrl(String url) async {
    _apiUrl = url;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiUrl', url);
    notifyListeners();
  }

  void setPrinterAddress(String address) async {
    _printerAddress = address;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerAddress', address);
    notifyListeners();
  }

  void setPrinterName(String name) async {
    _printerName = name;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('printerName', name);
    notifyListeners();
  }
}
