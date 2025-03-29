import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pos_indorep/model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IrepBE {
  bool isOffline = false;

  Future<String> getBaseUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? baseUrl = prefs.getString('apiUrl');
    if (baseUrl == null || baseUrl.isEmpty) {
      baseUrl = 'http://112.78.128.73:8085';
      await prefs.setString('apiUrl', baseUrl);
    }
    return baseUrl;
  }

  Future<List<MenuIrep>> getAllMenus() async {
    String baseUrl = await getBaseUrl();
    if (isOffline) {
      // Load local JSON file
      final String response =
          await rootBundle.loadString('assets/example.json');
      List<dynamic> data = json.decode(response);
      return data.map((item) => MenuIrep.fromMap(item, baseUrl)).toList();
    } else {
      String menuUrl = '${baseUrl}/menu';

      final response = await http.get(Uri.parse(menuUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => MenuIrep.fromMap(item, baseUrl)).toList();
      } else {
        print('Failed to load menus. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load menus');
      }
    }
  }

  Future<QrisOrderResponse> createOrder(QrisOrderRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/createOrder');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return QrisOrderResponse.fromJson(data);
      } else {
        print('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error creating order: $e');
    }

    // Return a default response instead of null
    return QrisOrderResponse(
      message: "Failed",
      orderID: 0,
      qris: "",
      success: false,
      total: 0,
    );
  }

  Future<AddMenuResponse> addMenu(AddMenuRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/addMenu');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AddMenuResponse.fromJson(data);
      } else {
        print('Failed to add menu: ${response.body}');
      }
    } catch (e) {
      print('Error adding menu: $e');
    }

    // Return a default response instead of null
    return AddMenuResponse(
      message: "Failed",
      menuId: 0,
      success: false,
    );
  }

  Future<EditMenuResponse> editMenu(AddMenuRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/editMenu');
    try {
      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print(data);
        return EditMenuResponse.fromJson(data);
      } else {
        print('Failed to edit menu: ${response.body}');
      }
    } catch (e) {
      print('Error edit menu: $e');
      rethrow;
    }

    // Return a default response instead of null
    return EditMenuResponse(
      message: "Failed",
      success: false,
    );
  }

  Future<DefaultResponse> deleteMenu(int id) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/deleteMenu');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({"id": id}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DefaultResponse.fromJson(data);
      } else {
        print('Failed to edit menu: ${response.body}');
      }
    } catch (e) {
      print('Error edit menu: $e');
      rethrow;
    }

    // Return a default response instead of null
    return DefaultResponse(
      message: "Failed",
      success: false,
    );
  }

  Future<AddOptionResponse> addOption(AddOptionRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/addOption');

    try {
      print(request.toJson());
      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AddOptionResponse.fromJson(data);
      } else {
        print('Failed to add option: ${response.body}');
      }
    } catch (e) {
      print('Error adding option: $e');
    }

    // Return a default response instead of null
    return AddOptionResponse(
      message: "Failed",
      optionId: 0,
      success: false,
    );
  }

  Future<AddOptionResponse> editOption(EditOptionRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/editOption');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(request.toJson()),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AddOptionResponse.fromJson(data);
      } else {
        print('Failed to add option: ${response.body}');
      }
    } catch (e) {
      print('Error adding option: $e');
    }

    // Return a default response instead of null
    return AddOptionResponse(
      message: "Failed",
      optionId: 0,
      success: false,
    );
  }

  Future<AddOptionValueResponse> addOptionValue(
      AddOptionValueRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/addOptionValue');

    try {
      final response = await http.post(
        url,
        body: jsonEncode([request.toJson()]),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return AddOptionValueResponse.fromJson(data);
      } else {
        print('Failed to add option: ${response.body}');
      }
    } catch (e) {
      print('Error adding option: $e');
    }

    // Return a default response instead of null
    return AddOptionValueResponse(
      message: "Failed",
      success: false,
    );
  }

  Future<DefaultResponse> editOptionValue(AddOptionValueRequest request) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/editOptionValue');

    try {
      final response = await http.post(
        url,
        body: jsonEncode([request.toJson()]),
      );
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DefaultResponse.fromJson(data);
      } else {
        print('Failed to add option: ${response.body}');
      }
    } catch (e) {
      print('Error adding option: $e');
    }

    // Return a default response instead of null
    return DefaultResponse(
      message: "Failed",
      success: false,
    );
  }

  Future<DefaultResponse> deleteOption(int optionId) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/deleteOption');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({"id": optionId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DefaultResponse.fromJson(data);
      } else {
        print('Failed to edit menu: ${response.body}');
      }
    } catch (e) {
      print('Error edit menu: $e');
      rethrow;
    }

    // Return a default response instead of null
    return DefaultResponse(
      message: "Failed",
      success: false,
    );
  }

  Future<DefaultResponse> deleteOptionValue(int optionValueId) async {
    String baseUrl = await getBaseUrl();
    final url = Uri.parse('${baseUrl}/deleteOptionValue');
    try {
      final response = await http.post(
        url,
        body: jsonEncode({"id": optionValueId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DefaultResponse.fromJson(data);
      } else {
        print('Failed to edit menu: ${response.body}');
      }
    } catch (e) {
      print('Error edit menu: $e');
      rethrow;
    }

    // Return a default response instead of null
    return DefaultResponse(
      message: "Failed",
      success: false,
    );
  }
}
