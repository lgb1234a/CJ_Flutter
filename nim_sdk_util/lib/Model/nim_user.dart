
import 'package:json_annotation/json_annotation.dart';

part 'nim_user.g.dart';

@JsonSerializable()
class Nim_user {
  final String userId;
  final String alias;
  NIMUserInfo userInfo;
  Nim_user (
    this.userId,
    this.alias,
  );
  
  //不同的类使用不同的mixin即可
  factory Nim_user.fromJson(Map<String, dynamic> json) => _$Nim_userFromJson(json);
  Map<String, dynamic> toJson() => _$Nim_userToJson(this); 
}

@JsonSerializable()
class NIMUserInfo {
  
  final String nickName;
  NIMUserInfo(
    this.nickName,
  );
  //不同的类使用不同的mixin即可
  factory NIMUserInfo.fromJson(Map<String, dynamic> json) => _$NIMUserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$NIMUserInfoToJson(this); 

}