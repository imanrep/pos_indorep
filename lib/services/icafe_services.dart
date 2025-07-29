import 'package:pos_indorep/web/model/pcs_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ICafeServices {
  Future<PcResponse> getPCs(String cafeId, String auth) async {
    final response = await http.get(
        Uri.parse('https://api.icafecloud.com/api/v2/cafe/$cafeId/pcs'),
        headers: {
          'Authorization': 'Bearer $auth',
        });
    if (response.statusCode == 200) {
      return PcResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load PCs');
    }
  }
}
