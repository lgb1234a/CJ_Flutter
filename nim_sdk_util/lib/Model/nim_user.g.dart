// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nim_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Nim_user _$Nim_userFromJson(Map<String, dynamic> json) {
  return Nim_user(
    json['userId'] as String,
    json['alias'] as String,
  )..userInfo = json['userInfo'] == null
      ? null
      : NIMUserInfo.fromJson(json['userInfo'] as Map<String, dynamic>);
}

Map<String, dynamic> _$Nim_userToJson(Nim_user instance) => <String, dynamic>{
      'userId': instance.userId,
      'alias': instance.alias,
      'userInfo': instance.userInfo,
    };

NIMUserInfo _$NIMUserInfoFromJson(Map<String, dynamic> json) {
  return NIMUserInfo(
    json['nickName'] as String,
  );
}

Map<String, dynamic> _$NIMUserInfoToJson(NIMUserInfo instance) =>
    <String, dynamic>{
      'nickName': instance.nickName,
    };
