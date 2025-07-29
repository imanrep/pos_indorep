class MembersResponse {
  final int code;
  final String message;
  final MembersData data;

  MembersResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory MembersResponse.fromJson(Map<String, dynamic> json) {
    return MembersResponse(
      code: json['code'],
      message: json['message'],
      data: MembersData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'data': data.toJson(),
      };
}

class MembersData {
  final int licenseUsingBilling;
  final int pointEnable;
  final List<Member> members;

  MembersData({
    required this.licenseUsingBilling,
    required this.pointEnable,
    required this.members,
  });

  factory MembersData.fromJson(Map<String, dynamic> json) {
    return MembersData(
      licenseUsingBilling: json['license_using_billing'],
      pointEnable: json['point_enable'],
      members: List<Member>.from(
        json['members'].map((x) => Member.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'license_using_billing': licenseUsingBilling,
        'point_enable': pointEnable,
        'members': List<dynamic>.from(members.map((x) => x.toJson())),
      };
}

class Member {
  final int memberId;
  final int memberIcafeId;
  final String memberAccount;
  final String memberBalance;
  final String memberFirstName;
  final String memberLastName;
  final String? memberBirthday;
  final String memberExpireTimeLocal;
  final int memberIsActive;
  final String memberPhoto;
  final String memberEmail;
  final String memberTelegramUsername;
  final int memberTelegramUsernameValid;
  final String memberPhone;
  final String memberIdCard;
  final String memberPoints;
  final String memberCreate;
  final String memberUpdate;
  final int memberGroupId;
  final String memberBalanceBonus;
  final String memberCoinBalance;
  final int memberSex;
  final String? memberComments;
  final String memberAddress;
  final int memberCompanyId;
  final String memberLoan;
  final String? memberRecentPlayed;
  final String memberIdIcafeId;
  final String memberOauthPlatform;
  final int memberReferrerId;
  final String memberOauthUserId;
  final String memberCreateLocal;
  final String memberUpdateLocal;
  final int memberIsExpired;
  final int memberIsLogined;
  final String memberPcName;
  final int offers;
  final int memberGroupDiscountRate;
  final int memberGroupDiscountPcTime;
  final int memberGroupDiscountOffer;
  final String memberGroupName;
  final String leftTime;
  final bool isOwner;
  final String memberCenterName;
  final String referrerAccount;

  Member({
    required this.memberId,
    required this.memberIcafeId,
    required this.memberAccount,
    required this.memberBalance,
    required this.memberFirstName,
    required this.memberLastName,
    required this.memberBirthday,
    required this.memberExpireTimeLocal,
    required this.memberIsActive,
    required this.memberPhoto,
    required this.memberEmail,
    required this.memberTelegramUsername,
    required this.memberTelegramUsernameValid,
    required this.memberPhone,
    required this.memberIdCard,
    required this.memberPoints,
    required this.memberCreate,
    required this.memberUpdate,
    required this.memberGroupId,
    required this.memberBalanceBonus,
    required this.memberCoinBalance,
    required this.memberSex,
    required this.memberComments,
    required this.memberAddress,
    required this.memberCompanyId,
    required this.memberLoan,
    required this.memberRecentPlayed,
    required this.memberIdIcafeId,
    required this.memberOauthPlatform,
    required this.memberReferrerId,
    required this.memberOauthUserId,
    required this.memberCreateLocal,
    required this.memberUpdateLocal,
    required this.memberIsExpired,
    required this.memberIsLogined,
    required this.memberPcName,
    required this.offers,
    required this.memberGroupDiscountRate,
    required this.memberGroupDiscountPcTime,
    required this.memberGroupDiscountOffer,
    required this.memberGroupName,
    required this.leftTime,
    required this.isOwner,
    required this.memberCenterName,
    required this.referrerAccount,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['member_id'],
      memberIcafeId: json['member_icafe_id'],
      memberAccount: json['member_account'],
      memberBalance: json['member_balance'],
      memberFirstName: json['member_first_name'],
      memberLastName: json['member_last_name'],
      memberBirthday: json['member_birthday'],
      memberExpireTimeLocal: json['member_expire_time_local'],
      memberIsActive: json['member_is_active'],
      memberPhoto: json['member_photo'],
      memberEmail: json['member_email'],
      memberTelegramUsername: json['member_telegram_username'],
      memberTelegramUsernameValid: json['member_telegram_username_valid'],
      memberPhone: json['member_phone'],
      memberIdCard: json['member_id_card'],
      memberPoints: json['member_points'],
      memberCreate: json['member_create'],
      memberUpdate: json['member_update'],
      memberGroupId: json['member_group_id'],
      memberBalanceBonus: json['member_balance_bonus'],
      memberCoinBalance: json['member_coin_balance'],
      memberSex: json['member_sex'],
      memberComments: json['member_comments'],
      memberAddress: json['member_address'],
      memberCompanyId: json['member_company_id'],
      memberLoan: json['member_loan'],
      memberRecentPlayed: json['member_recent_played'],
      memberIdIcafeId: json['member_id_icafe_id'],
      memberOauthPlatform: json['member_oauth_platform'],
      memberReferrerId: json['member_referrer_id'],
      memberOauthUserId: json['member_oauth_user_id'],
      memberCreateLocal: json['member_create_local'],
      memberUpdateLocal: json['member_update_local'],
      memberIsExpired: json['member_is_expired'],
      memberIsLogined: json['member_is_logined'],
      memberPcName: json['member_pc_name'],
      offers: json['offers'],
      memberGroupDiscountRate: json['member_group_discount_rate'],
      memberGroupDiscountPcTime: json['member_group_discount_pc_time'],
      memberGroupDiscountOffer: json['member_group_discount_offer'],
      memberGroupName: json['member_group_name'],
      leftTime: json['left_time'],
      isOwner: json['is_owner'],
      memberCenterName: json['member_center_name'],
      referrerAccount: json['referrer_account'],
    );
  }

  Map<String, dynamic> toJson() => {
        'member_id': memberId,
        'member_icafe_id': memberIcafeId,
        'member_account': memberAccount,
        'member_balance': memberBalance,
        'member_first_name': memberFirstName,
        'member_last_name': memberLastName,
        'member_birthday': memberBirthday,
        'member_expire_time_local': memberExpireTimeLocal,
        'member_is_active': memberIsActive,
        'member_photo': memberPhoto,
        'member_email': memberEmail,
        'member_telegram_username': memberTelegramUsername,
        'member_telegram_username_valid': memberTelegramUsernameValid,
        'member_phone': memberPhone,
        'member_id_card': memberIdCard,
        'member_points': memberPoints,
        'member_create': memberCreate,
        'member_update': memberUpdate,
        'member_group_id': memberGroupId,
        'member_balance_bonus': memberBalanceBonus,
        'member_coin_balance': memberCoinBalance,
        'member_sex': memberSex,
        'member_comments': memberComments,
        'member_address': memberAddress,
        'member_company_id': memberCompanyId,
        'member_loan': memberLoan,
        'member_recent_played': memberRecentPlayed,
        'member_id_icafe_id': memberIdIcafeId,
        'member_oauth_platform': memberOauthPlatform,
        'member_referrer_id': memberReferrerId,
        'member_oauth_user_id': memberOauthUserId,
        'member_create_local': memberCreateLocal,
        'member_update_local': memberUpdateLocal,
        'member_is_expired': memberIsExpired,
        'member_is_logined': memberIsLogined,
        'member_pc_name': memberPcName,
        'offers': offers,
        'member_group_discount_rate': memberGroupDiscountRate,
        'member_group_discount_pc_time': memberGroupDiscountPcTime,
        'member_group_discount_offer': memberGroupDiscountOffer,
        'member_group_name': memberGroupName,
        'left_time': leftTime,
        'is_owner': isOwner,
        'member_center_name': memberCenterName,
        'referrer_account': referrerAccount,
      };
}
