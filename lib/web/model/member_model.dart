class Member {
  final int memberId;
  final String memberAccount;
  final double memberBalance; // from string
  final String memberExpireTimeLocal;
  final int memberIsActive;
  final String memberCreateLocal;
  final String memberUpdateLocal;
  final int memberIsExpired;
  final int memberIsLogined;
  final String memberGroupName;
  final String leftTime;

  Member({
    required this.memberId,
    required this.memberAccount,
    required this.memberBalance,
    required this.memberExpireTimeLocal,
    required this.memberIsActive,
    required this.memberCreateLocal,
    required this.memberUpdateLocal,
    required this.memberIsExpired,
    required this.memberIsLogined,
    required this.memberGroupName,
    required this.leftTime,
  });

  factory Member.fromJson(Map<String, dynamic> j) => Member(
        memberId: (j['member_id'] as num).toInt(),
        memberAccount: j['member_account'] ?? '',
        memberBalance:
            double.tryParse(j['member_balance']?.toString() ?? '0') ?? 0.0,
        memberExpireTimeLocal: j['member_expire_time_local'] ?? '',
        memberIsActive: (j['member_is_active'] as num?)?.toInt() ?? 0,
        memberCreateLocal: j['member_create_local'] ?? '',
        memberUpdateLocal: j['member_update_local'] ?? '',
        memberIsExpired: (j['member_is_expired'] as num?)?.toInt() ?? 0,
        memberIsLogined: (j['member_is_logined'] as num?)?.toInt() ?? 0,
        memberGroupName: j['member_group_name'] ?? '',
        leftTime: j['left_time'] ?? '',
      );
}

class PagingInfo {
  final int totalRecords;
  final int pages;
  final int page;

  PagingInfo({
    required this.totalRecords,
    required this.pages,
    required this.page,
  });

  factory PagingInfo.fromJson(Map<String, dynamic> j) {
    final pageStr = j['page']?.toString() ?? '1';
    return PagingInfo(
      totalRecords: (j['total_records'] as num?)?.toInt() ?? 0,
      pages: (j['pages'] as num?)?.toInt() ?? 1,
      page: int.tryParse(pageStr) ?? 1,
    );
  }
}

class MembersData {
  final int licenseUsingBilling;
  final int pointEnable;
  final List<Member> members;
  final PagingInfo pagingInfo;

  MembersData({
    required this.licenseUsingBilling,
    required this.pointEnable,
    required this.members,
    required this.pagingInfo,
  });

  factory MembersData.fromJson(Map<String, dynamic> j) => MembersData(
        licenseUsingBilling: (j['license_using_billing'] as num?)?.toInt() ?? 0,
        pointEnable: (j['point_enable'] as num?)?.toInt() ?? 0,
        members: (j['members'] as List? ?? [])
            .map((e) => Member.fromJson(e as Map<String, dynamic>))
            .toList(),
        pagingInfo:
            PagingInfo.fromJson(j['paging_info'] as Map<String, dynamic>),
      );
}

class MembersSection {
  final int code;
  final String message;
  final MembersData data;

  MembersSection({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MembersSection.fromJson(Map<String, dynamic> j) => MembersSection(
        code: (j['code'] as num?)?.toInt() ?? 0,
        message: j['message'] ?? '',
        data: MembersData.fromJson(j['data'] as Map<String, dynamic>),
      );
}

class GetCustomersResponse {
  final MembersSection members;
  final int totalTransactions;

  GetCustomersResponse({
    required this.members,
    required this.totalTransactions,
  });

  factory GetCustomersResponse.fromJson(Map<String, dynamic> j) =>
      GetCustomersResponse(
        members: MembersSection.fromJson(j['members'] as Map<String, dynamic>),
        totalTransactions: (j['totalTransactions'] as num?)?.toInt() ?? 0,
      );
}

/// Optional: a simple result type for the aggregated fetch
class AllCustomersResult {
  final List<Member> members;
  final int totalTransactions;
  final int totalRecords; // from first page
  final int pages;

  AllCustomersResult({
    required this.members,
    required this.totalTransactions,
    required this.totalRecords,
    required this.pages,
  });
}
