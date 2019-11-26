import 'dart:async';
import 'package:flutter/services.dart';
// import 'Model/nim_contactModel.dart';
// import 'Model/nim_teamModel.dart';
// import 'Model/nim_userInfo.dart';
import 'Model/nim_model.dart';

class NimSdkUtil {
  static const MethodChannel _channel = const MethodChannel('nim_sdk_util');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 注册云信sdk
  static Future<void> doRegisterSDK() async {
    await _channel.invokeMethod('registerSDK');
  }

  /// sdk登录
  static Future<bool> doSDKLogin(
      String accid, String token, String name) async {
    bool success =
        await _channel.invokeMethod('doLogin:', [accid, token, name]);
    return success;
  }

  /// 自动登录
  static void autoLogin(String accid, String token, String name) {
    _channel.invokeMethod('autoLogin:', [accid, token, name]);
  }

  /// 登出
  static void logout() {
    _channel.invokeMethod('logout');
  }

  /// 获取群信息
  static Future<TeamInfo> teamInfoById(String teamId) async {
    dynamic teamInfo = await _channel.invokeMethod('teamInfo:', [teamId]);
    return TeamInfo.fromJson(teamInfo);
  }

  /// 获取用户信息
  /// userId 选填，不填默认获取当前用户信息
  static Future<UserInfo> userInfoById({String userId}) async {
    dynamic userInfo = await _channel.invokeMethod('userInfo:', [userId]);
    return UserInfo.fromJson(userInfo);
  }

  /// 获取好友列表
  static Future<List<ContactInfo>> friends() async {
    List friends = await _channel.invokeMethod('friends:');
    return friends.map((f) => ContactInfo.fromJson(f)).toList();
  }

  /// 群聊列表
  static Future<List<Team>> allMyTeams() async {
    List teams = await _channel.invokeMethod('allMyTeams:');
    return teams.map((f) => Team.fromJson(f)).toList();
  }

  /// 群成员信息
  static Future<List<TeamMemberInfo>> teamMemberInfos(String teamId) async {
    List teamMemberInfos =
        await _channel.invokeMethod('teamMemberInfos:', [teamId]);
    return teamMemberInfos.map((f) => TeamMemberInfo.fromJson(f)).toList();
  }

  /// 获取单个群成员信息
  static Future<TeamMemberInfo> teamMemberInfoById(
      String teamId, String userId) async {
    Map memberInfo = await _channel.invokeMethod('teamMemberInfo:', [teamId, userId]);
    return TeamMemberInfo.fromJson(memberInfo);
  }

  /// 获取会话置顶状态
  static Future<bool> isStickedOnTop(Session session) async {
    bool isTop = await _channel
        .invokeMethod('isStickedOnTop:', [session.id, session.type]);
    return isTop;
  }

  /// 获取会话是否开启消息提醒
  static Future<bool> isNotifyForNewMsg(String sessionId) async {
    bool isTop = await _channel.invokeMethod('isNotifyForNewMsg:', [sessionId]);
    return isTop;
  }

  /// 删除聊天记录
  static Future<void> clearChatHistory(Session session) async {
    await _channel
        .invokeMethod('clearChatHistory:', [session.id, session.type]);
  }

  /// 聊天置顶开关
  static Future<void> stickSessiOnTop(Session session, bool isTop) async {
    await _channel
        .invokeMethod('stickSessiOnTop:', [session.id, session.type, isTop]);
  }

  /// 消息通知开关
  static Future<bool> changeNotifyStatus(
      Session session, bool needNotify) async {
    bool success = await _channel.invokeMethod(
        'changeNotifyStatus:', [session.id, session.type, needNotify]);
    return success;
  }

  /// 退出群聊
  static Future<void> quitTeam(String teamId) async {
    await _channel.invokeMethod('quitTeam:', [teamId]);
  }
}
