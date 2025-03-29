import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainProvider extends ChangeNotifier {
  String _apiUrl = '';
  String _mainRepo = '';
  String _appVersion = '';

  String get apiUrl => _apiUrl;
  String get mainRepo => _mainRepo;
  String get appVersion => _appVersion;

  MainProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadApiUrl();
    loadAppVersion();
  }

  Future<void> _loadApiUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('apiUrl')) {
      await prefs.setString('apiUrl', 'http://112.78.128.73:8085');
    } else {
      _apiUrl = prefs.getString('apiUrl') ?? 'http://112.78.128.73:8085';
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
}
