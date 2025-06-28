import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pos_indorep/services/irepbe_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  String _apiUrl = '';
  String _mainRepo = '';
  String _appVersion = '';
  String _printerAddress = '';
  String _printerName = '';
  String _latestVersion = '';
  bool _isUpdateAvailable = false;
  String? _updateUrl;

  String get apiUrl => _apiUrl;
  String get mainRepo => _mainRepo;
  String get appVersion => _appVersion;
  String get printerAddress => _printerAddress;
  String get printerName => _printerName;
  String get latestVersion => _latestVersion;
  bool get isUpdateAvailable => _isUpdateAvailable;
  String? get updateUrl => _updateUrl;

  MainProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadApiUrl();
    await _loadPrinterAddress();
    await _loadPrinterName();
    await loadAppVersion();

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

  Future<void> loadAppVersion() async {
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

  Future<void> checkForAppUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    var irepBE = IrepBE();

    final fetchedVersion = await irepBE.fetchLatestVersionTag();
    if (fetchedVersion == null) {
      debugPrint('Could not fetch latest version');
      return;
    }

    _latestVersion = fetchedVersion;
    _isUpdateAvailable = _isNewerVersion(fetchedVersion, appVersion);

    if (isUpdateAvailable) {
      _updateUrl = await irepBE.fetchDownloadUrlForVersion(fetchedVersion);
    }

    notifyListeners();
  }

  bool _isNewerVersion(String latest, String current) {
    final l = latest.split('.').map(int.parse).toList();
    final c = current.split('.').map(int.parse).toList();
    for (int i = 0; i < l.length; i++) {
      if (i >= c.length || l[i] > c[i]) return true;
      if (l[i] < c[i]) return false;
    }
    return false;
  }
  
}
