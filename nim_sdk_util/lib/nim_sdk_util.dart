import 'dart:async';
import 'package:flutter/services.dart';
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
    bool success = await _channel.invokeMethod(
        'doLogin:', {'accid': accid, 'token': token, 'name': name});
    return success;
  }

  /// 自动登录
  static void autoLogin(String accid, String token, String name) {
    _channel.invokeMethod(
        'autoLogin:', {'accid': accid, 'token': token, 'name': name});
  }

  /// 登出
  static void logout() {
    _channel.invokeMethod('logout');
  }

  /// 获取群信息
  static Future<TeamInfo> teamInfoById(String teamId) async {
    dynamic teamInfo =
        await _channel.invokeMethod('teamInfo:', {'teamId': teamId});
    return TeamInfo.fromJson(teamInfo);
  }

  /// 获取用户信息
  /// userId 选填，不填默认获取当前用户信息
  static Future<UserInfo> userInfoById({String userId}) async {
    dynamic userInfo =
        await _channel.invokeMethod('userInfo:', {'userId': userId});
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
        await _channel.invokeMethod('teamMemberInfos:', {'teamId': teamId});
    return teamMemberInfos.map((f) => TeamMemberInfo.fromJson(f)).toList();
  }

  /// 获取单个群成员信息
  static Future<TeamMemberInfo> teamMemberInfoById(
      String teamId, String userId) async {
    Map memberInfo = await _channel
        .invokeMethod('teamMemberInfo:', {'teamId': teamId, 'userId': userId});
    return TeamMemberInfo.fromJson(memberInfo);
  }

  /// 获取会话置顶状态
  static Future<bool> isStickedOnTop(Session session) async {
    bool isTop = await _channel.invokeMethod(
        'isStickedOnTop:', {'id': session.id, 'type': session.type});
    return isTop;
  }

  /// 获取会话是否开启消息提醒
  static Future<bool> isNotifyForNewMsg(Session session) async {
    bool isTop = await _channel.invokeMethod(
        'isNotifyForNewMsg:', {'id': session.id, 'type': session.type});
    return isTop;
  }

  /// 删除聊天记录
  static Future<void> clearChatHistory(Session session) async {
    await _channel.invokeMethod(
        'clearChatHistory:', {'id': session.id, 'type': session.type});
  }

  /// 聊天置顶开关
  static Future<void> stickSessinOnTop(Session session, bool isTop) async {
    await _channel.invokeMethod('stickSessinOnTop:',
        {'id': session.id, 'type': session.type, 'isTop': isTop});
  }

  /// 消息通知开关
  static Future<bool> changeNotifyStatus(
      Session session, bool needNotify) async {
    bool success = await _channel.invokeMethod('changeNotifyStatus:',
        {'id': session.id, 'type': session.type, 'needNotify': needNotify});
    return success;
  }

  /// 退出群聊
  static Future<bool> quitTeam(String teamId) async {
    return await _channel.invokeMethod('quitTeam:', {'teamId': teamId});
  }

  /// 解散群聊
  static Future<bool> dismissTeam(String teamId) async {
    return await _channel.invokeMethod('dismissTeam:', {'teamId': teamId});
  }
  
  /// 判断用户是否被拉黑
  static Future<bool> isUserBlocked(String userId) async {
    return await _channel.invokeMethod('isUserBlocked:', {'userId': userId});
  }

  /// 把用户拉黑
  static Future<bool> blockUser(String userId) async {
    return await _channel.invokeMethod('blockUser:', {'userId': userId});
  }

  /// 移出黑名单
  static Future<bool> cancelBlockUser(String userId) async {
    return await _channel.invokeMethod('cancelBlockUser:', {'userId': userId});
  }

  /// 获取黑名单成员列表
  static Future<List<String>> blockUserList() async {
    return await _channel.invokeMethod('blockUserList:');
  }
}
