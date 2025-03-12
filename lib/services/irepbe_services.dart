import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pos_indorep/model/model.dart';

class IrepBE {
  // String baseUrl = 'http://118.99.122.171:8085/';
  String baseUrl = 'http://192.168.5.254:8085/';

  bool isOffline = true;

  Future<List<MenuIrep>> getAllMenus() async {
    if (isOffline) {
      // Load local JSON file
      final String response =
          await rootBundle.loadString('assets/example.json');
      List<dynamic> data = json.decode(response);
      return data.map((item) => MenuIrep.fromMap(item)).toList();
    } else {
      String menuUrl = '${baseUrl}menu';

      final response = await http.get(Uri.parse(menuUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MenuIrep.fromMap(item)).toList();
      } else {
        print('Failed to load menus. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load menus');
      }
    }
  }
}
