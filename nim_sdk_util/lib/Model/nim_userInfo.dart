///
/// created by chenyn 2019-10-28
/// 用户信息model
///

class UserInfo {
  String userId;
  String showName;
  String avatarUrlString;
  String thumbAvatarUrl;
  String sign;
  /* 0:未知  1:男  2:女 */
  int gender;
  String email;
  String birth;
  String mobile;
  String cajianNo;
  /* 别名备注 */
  String alias;


  UserInfo.fromJson(Map json)
      : userId = json['userId'],
        showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        thumbAvatarUrl = json['thumbAvatarUrl'],
        sign = json['sign'],
        gender = json['gender'],
        email = json['email'],
        birth = json['birth'],
        mobile = json['mobile'],
        cajianNo = json['cajianNo'],
        alias = json['alias'];
}
