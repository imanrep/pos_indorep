import 'dart:convert';

class PcResponse {
  final int code;
  final String message;
  final Data data;

  PcResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PcResponse.fromJson(Map<String, dynamic> json) {
    return PcResponse(
      code: json['code'],
      message: json['message'],
      data: Data.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class Data {
  final PcsInit pcsInit;

  Data({
    required this.pcsInit,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      pcsInit: PcsInit.fromJson(json['pcs_init']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pcs_init': pcsInit.toJson(),
    };
  }
}

class PcsInit {
  final List<Pc> pcList;

  PcsInit({
    required this.pcList,
  });

  factory PcsInit.fromJson(Map<String, dynamic> json) {
    var list = json['pc_list'] as List;
    List<Pc> pcList = list.map((i) => Pc.fromJson(i)).toList();

    return PcsInit(pcList: pcList);
  }

  Map<String, dynamic> toJson() {
    return {
      'pc_list': pcList.map((i) => i.toJson()).toList(),
    };
  }
}

class Pc {
  final String pcName;
  final String? statusConnectTimeLocal;
  final String? memberAccount;

  Pc({
    required this.pcName,
    this.statusConnectTimeLocal,
    this.memberAccount,
  });

  factory Pc.fromJson(Map<String, dynamic> json) {
    return Pc(
      pcName: json['pc_name'],
      statusConnectTimeLocal: json['status_connect_time_local'],
      memberAccount: json['member_account'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pc_name': pcName,
      'status_connect_time_local': statusConnectTimeLocal,
      'member_account': memberAccount,
    };
  }
}

void main() {
  String jsonString = '''{
    "code": 200,
    "message": "success",
    "data": {
        "pcs_init": {
            "pc_list": [
                {
                    "pc_name": "INDOREP-01",
                    "status_connect_time_local": null,
                    "member_account": null
                },
                {
                    "pc_name": "INDOREP-02",
                    "status_connect_time_local": null,
                    "member_account": null
                }
            ]
        }
    }
  }''';

  // Parse JSON into the ApiResponse object
  Map<String, dynamic> jsonData = jsonDecode(jsonString);
  PcResponse apiResponse = PcResponse.fromJson(jsonData);

  // Print the data
  print('API Response: ${apiResponse.message}');
  for (var pc in apiResponse.data.pcsInit.pcList) {
    print('PC Name: ${pc.pcName}');
    print('Status Connect Time: ${pc.statusConnectTimeLocal}');
    print('Member Account: ${pc.memberAccount}');
  }

  // Convert the ApiResponse back to JSON
  String jsonStringBack = jsonEncode(apiResponse.toJson());
  print('JSON Back: $jsonStringBack');
}
