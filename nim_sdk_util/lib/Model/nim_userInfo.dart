/**
 * created by chenyn 2019-10-28
 * 用户信息model
 */
import 'dart:typed_data';

class CurrentUserInfo {
  String showName;
  String avatarUrlString;
  String thumbAvatarUrl;
  String sign;
  int gender;
  String email;
  String birth;
  String mobile;
  String cajianNo;

  CurrentUserInfo.fromJson(Map json)
      : showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        thumbAvatarUrl = json['thumbAvatarUrl'],
        sign = json['sign'],
        gender = json['gender'],
        email = json['email'],
        birth = json['birth'],
        mobile = json['mobile'],
        cajianNo = json['cajianNo'];
}

class UserInfo {
  String showName;
  String avatarUrlString;
  Uint8List avatarImage;

  UserInfo.fromJson(Map json)
      : showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        avatarImage = json['avatarImage'];
}
