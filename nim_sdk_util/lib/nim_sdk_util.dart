import 'dart:async';
import 'package:flutter/services.dart';
import 'Model/nim_contactModel.dart';
import 'Model/nim_teamModel.dart';
import 'Model/nim_userInfo.dart';

class NimSdkUtil {
  static const MethodChannel _channel =
      const MethodChannel('nim_sdk_util');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 注册云信sdk
  static Future<void> doRegisterSDK() async{
    await _channel.invokeMethod('registerSDK');
  }

  /// sdk登录
  static Future<bool> doSDKLogin(
    String accid, 
    String token, 
    String name) async 
  {
    bool success = await _channel.invokeMethod('doLogin:', [accid, token, name]);
    return success;
  }

  /// 自动登录
  static void autoLogin(
    String accid, 
    String token, 
    String name){
    _channel.invokeMethod('autoLogin:', [accid, token, name]);
  }

  /// 登出
  static void logout() {
    _channel.invokeMethod('logout');
  }

  // 当前用户信息
  static Future<CurrentUserInfo>currentUserInfo() async {
    dynamic info = await _channel.invokeMethod('currentUserInfo:');
    return CurrentUserInfo.fromJson(info);
  }

  // 获取群信息
  static Future<TeamInfoFromId>teamInfoById(String teamId) async {
    dynamic teamInfo = await _channel.invokeMethod('teamInfo:', [teamId]);
    return TeamInfoFromId.fromJson(teamInfo);
  }

  // 获取用户信息
  static Future<UserInfo>userInfoById(String sessionId) async {
    dynamic userInfo = await _channel.invokeMethod('userInfo:', [sessionId]);
    return UserInfo.fromJson(userInfo);
  }

  // 获取好友列表
  static Future<List<ContactInfo>>friends() async {
    List friends = await _channel.invokeMethod('friends:');
    return friends.map((f)=>ContactInfo.fromJson(f)).toList();
  }

  // 群聊列表
  static Future<List<TeamInfo>>allMyTeams() async {
    List teams = await _channel.invokeMethod('allMyTeams:');
    return teams.map((f)=>TeamInfo.fromJson(f)).toList();
  }

  // 群成员信息
  static Future<List<TeamMemberInfo>>teamMemberInfos(String teamId) async {
    List teamMemberInfos = await _channel.invokeMethod('teamMemberInfos:', [teamId]);
    return teamMemberInfos.map((f)=>TeamMemberInfo.fromJson(f)).toList();
  }

  // 获取会话置顶状态
  static Future<bool> isStickedOnTop(String sessionId, int sessionType) async {
    bool isTop = await _channel.invokeMethod('isStickedOnTop:', [sessionId, sessionType]);
    return isTop;
  }

  // 获取会话是否开启消息提醒
  static Future<bool> isNotifyForNewMsg(String sessionId) async {
    bool isTop = await _channel.invokeMethod('isNotifyForNewMsg:', [sessionId]);
    return isTop;
  }
}
