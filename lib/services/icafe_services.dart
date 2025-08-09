import 'package:pos_indorep/web/model/pcs_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ICafeServices {
  final String cafeId = '';

  Future<PcResponse> getPCs(String cafeId, String authToken) async {
    final response = await http.get(
        Uri.parse('https://api.icafecloud.com/api/v2/cafe/$cafeId/pcs'),
        headers: {
          'Authorization': 'Bearer $authToken',
        });
    if (response.statusCode == 200) {
      return PcResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load PCs');
    }
  }

  Future<bool> checkApiStatus(String cafeId, String authToken) async {
    try {
      PcResponse response = await getPCs(cafeId, authToken);
      if (response.data.isNotEmpty) {
        print('API is online');
        return true;
      } else {
        print('API is offline');
        return false;
      }
    } catch (e) {
      print('API is offline: $e');
      return false;
    }
  }

  Future<bool> setICafeApiKey(String apiKey) async {
    try {
      var response = await http.post(
        Uri.parse('https://warnet-api.indorep.com/change_api'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'api': apiKey}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to set API key: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Failed to set API key: $e');
      return false;
    }
  }
}
