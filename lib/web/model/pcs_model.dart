class PcResponse {
  final int code;
  final String message;
  final List<PcData> data;

  PcResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PcResponse.fromJson(Map<String, dynamic> json) {
    return PcResponse(
      code: json['code'],
      message: json['message'],
      data: List<PcData>.from(json['data'].map((x) => PcData.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class PcData {
  final int pcIcafeId;
  final String pcIp;
  final String pcName;
  final String pcMac;
  final String pcComment;
  final int pcConsoleType;
  final int pcGroupId;
  final String pcAreaName;
  final String pcBoxPosition;
  final int? pcBoxTop;
  final int? pcBoxLeft;
  final int pcEnabled;
  final int pcMiningEnabled;
  final String pcMiningTool;
  final String pcMiningOptions;
  final int pcInUsing;

  PcData({
    required this.pcIcafeId,
    required this.pcIp,
    required this.pcName,
    required this.pcMac,
    required this.pcComment,
    required this.pcConsoleType,
    required this.pcGroupId,
    required this.pcAreaName,
    required this.pcBoxPosition,
    this.pcBoxTop,
    this.pcBoxLeft,
    required this.pcEnabled,
    required this.pcMiningEnabled,
    required this.pcMiningTool,
    required this.pcMiningOptions,
    required this.pcInUsing,
  });

  factory PcData.fromJson(Map<String, dynamic> json) {
    return PcData(
      pcIcafeId: json['pc_icafe_id'],
      pcIp: json['pc_ip'],
      pcName: json['pc_name'],
      pcMac: json['pc_mac'],
      pcComment: json['pc_comment'],
      pcConsoleType: json['pc_console_type'],
      pcGroupId: json['pc_group_id'],
      pcAreaName: json['pc_area_name'],
      pcBoxPosition: json['pc_box_position'],
      pcBoxTop: json['pc_box_top'],
      pcBoxLeft: json['pc_box_left'],
      pcEnabled: json['pc_enabled'],
      pcMiningEnabled: json['pc_mining_enabled'],
      pcMiningTool: json['pc_mining_tool'],
      pcMiningOptions: json['pc_mining_options'],
      pcInUsing: json['pc_in_using'],
    );
  }

  Map<String, dynamic> toJson() => {
        'pc_icafe_id': pcIcafeId,
        'pc_ip': pcIp,
        'pc_name': pcName,
        'pc_mac': pcMac,
        'pc_comment': pcComment,
        'pc_console_type': pcConsoleType,
        'pc_group_id': pcGroupId,
        'pc_area_name': pcAreaName,
        'pc_box_position': pcBoxPosition,
        'pc_box_top': pcBoxTop,
        'pc_box_left': pcBoxLeft,
        'pc_enabled': pcEnabled,
        'pc_mining_enabled': pcMiningEnabled,
        'pc_mining_tool': pcMiningTool,
        'pc_mining_options': pcMiningOptions,
        'pc_in_using': pcInUsing,
      };
}
