import 'package:pos_indorep/web/model/create_member_request.dart';
import 'package:pos_indorep/web/model/create_member_response.dart';
import 'package:pos_indorep/web/model/create_order_kulkas_request.dart';
import 'package:pos_indorep/web/model/create_order_kulkas_response.dart';
import 'package:pos_indorep/web/model/kulkas_item_response.dart';
import 'package:pos_indorep/web/model/member_model.dart';
import 'package:pos_indorep/web/model/pcs_model.dart';
import 'package:http/http.dart' as http;
import 'package:pos_indorep/web/model/topup_member_request.dart';
import 'dart:convert';

import 'package:pos_indorep/web/model/topup_member_response.dart';

class WarnetBackendServices {
  Future<PcResponse> getPCs() async {
    final response = await http.get(
      Uri.parse('https://warnet-api.indorep.com/getPcs'),
    );
    if (response.statusCode == 200) {
      return PcResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load PCs');
    }
  }

  Future<bool> checkApiStatus(String cafeId, String authToken) async {
    try {
      PcResponse response = await getPCs();
      if (response.data.pcsInit.pcList.isNotEmpty) {
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

  Future<GetCustomersResponse> _fetchCustomersPage({
    required String text,
    required int page,
  }) async {
    final uri = Uri.parse("https://warnet-api.indorep.com/getCustomers");

    final body = jsonEncode({'text': text, 'page': page});

    final res = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return GetCustomersResponse.fromJson(map);
  }

  Future<AllCustomersResult> fetchAllCustomers(String text) async {
    // 1) Get page 1
    final first = await _fetchCustomersPage(text: text, page: 1);

    final firstData = first.members.data;
    final pages = firstData.pagingInfo.pages;
    final totalRecords = firstData.pagingInfo.totalRecords;

    // Aggregate
    final all = <Member>[...firstData.members];

    // 2) Loop remaining pages (if any)
    for (int p = 2; p <= pages; p++) {
      final resp = await _fetchCustomersPage(text: text, page: p);
      all.addAll(resp.members.data.members);
    }

    return AllCustomersResult(
      members: all,
      totalTransactions: first.totalTransactions,
      totalRecords: totalRecords,
      pages: pages,
    );
  }

  Future<CreateMemberResponse> createMember(CreateMemberRequest request) async {
    final uri = Uri.parse("https://warnet-api.indorep.com/createMember");

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      return CreateMemberResponse.fromJson(jsonDecode(res.body));
    } catch (e) {
      // You can log the error or handle it as needed
      print('Failed to create member: $e');
      rethrow; // or return a default error response if you prefer
    }
  }

  Future<TopUpMemberResponse> topUpMember(TopUpMemberRequest request) async {
    final uri = Uri.parse("https://warnet-api.indorep.com/topupMember");

    try {
      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      return TopUpMemberResponse.fromJson(jsonDecode(res.body));
    } catch (e) {
      // You can log the error or handle it as needed
      print('Failed to create member: $e');
      rethrow; // or return a default error response if you prefer
    }
  }

  Future<GetKulkasItemResponse> getKulkasItem() async {
    final uri = Uri.parse("https://warnet-api.indorep.com/kulkas_item");

    try {
      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }
      return GetKulkasItemResponse.fromJson(jsonDecode(res.body));
    } catch (e) {
      // You can log the error or handle it as needed
      print('Failed to get kulkas items: $e');
      rethrow; // or return a default error response if you prefer
    }
  }

  Future<CreateOrderKulkasResponse> createKulkasOrder(
      CreateOrderKulkasRequest request) async {
    const String url = "https://warnet-api.indorep.com/createOrderKulkas";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return CreateOrderKulkasResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            "Failed to create order: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating order: $e");
    }
  }
}
