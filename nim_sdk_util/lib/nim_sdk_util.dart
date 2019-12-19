import 'dart:async';
import 'dart:io';
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
  static Future<bool> doSDKLogin(String accid, String token,
      {String name}) async {
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
  static Future<List<dynamic>> blockUserList() async {
    return await _channel.invokeMethod('blockUserList:');
  }

  /// 更新成员群昵称
  static Future<bool> updateUserNickName(
      String nickName, String userId, String teamId) async {
    return await _channel.invokeMethod('updateUserNickName:',
        {'nickName': nickName, 'userId': userId, 'teamId': teamId});
  }

  /// 更新群名称
  static Future<bool> updateTeamName(String teamName, String teamId) async {
    return await _channel.invokeMethod(
        'updateTeamName:', {'teamName': teamName, 'teamId': teamId});
  }

  /// 更新群公告
  static Future<bool> updateAnnouncement(
      String announcement, String teamId) async {
    return await _channel.invokeMethod('updateAnnouncement:',
        {'announcement': announcement, 'teamId': teamId});
  }

  /// 上传文件到云信服务器
  static Future<String> uploadFileToNim(File file) async {
    return await _channel
        .invokeMethod('uploadFileToNim:', {'filePath': file.path});
  }

  /// 替换群头像
  static Future<bool> updateTeamAvatar(String teamId, String avatarUrl) async {
    return await _channel.invokeMethod(
        'updateTeamAvatar:', {'teamId': teamId, 'avatarUrl': avatarUrl});
  }

  /// 删除好友
  static Future<bool> deleteContact(String userId) async {
    return await _channel.invokeMethod('deleteContact:', {'userId': userId});
  }

  /// 设置是否允许该用户消息的通知
  static Future<bool> allowUserMsgNotify(
      String userId, bool allowNotify) async {
    return await _channel.invokeMethod(
        'allowUserMsgNotify:', {'userId': userId, 'allowNotify': allowNotify});
  }

  /// 获取系统消息通知
  static Future<List<SystemNotification>> fetchSystemNotifications() async {
    List<dynamic> notifications =
        await _channel.invokeMethod('fetchSystemNotifications:');
    return notifications.map((f) => SystemNotification.fromJson(f)).toList();
  }

  /// 删除所有的系统消息通知
  static Future<void> deleteAllNotifications() async {
    await _channel.invokeMethod('deleteAllNotifications');
  }

  /// 同意入群申请
  static Future<NotificationHandleType> passApplyToTeam(
      String targetID, String sourceID) async {
    int resultType = await _channel.invokeMethod(
        'passApplyToTeam:', {'targetID': targetID, 'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 拒绝入群申请
  static Future<NotificationHandleType> rejectApplyToTeam(
      String targetID, String sourceID) async {
    int resultType = await _channel.invokeMethod(
        'rejectApplyToTeam:', {'targetID': targetID, 'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 接受入群邀请
  static Future<NotificationHandleType> acceptInviteWithTeam(
      String targetID, String sourceID) async {
    int resultType = await _channel.invokeMethod(
        'acceptInviteWithTeam:', {'targetID': targetID, 'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 拒绝入群邀请
  static Future<NotificationHandleType> rejectInviteWithTeam(
      String targetID, String sourceID) async {
    int resultType = await _channel.invokeMethod(
        'rejectInviteWithTeam:', {'targetID': targetID, 'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 通过添加好友请求
  static Future<NotificationHandleType> requestFriend(String sourceID) async {
    int resultType =
        await _channel.invokeMethod('requestFriend:', {'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 拒绝好友添加申请
  static Future<NotificationHandleType> rejectFriendRequest(
      String sourceID) async {
    int resultType = await _channel
        .invokeMethod('rejectFriendRequest:', {'sourceID': sourceID});
    return NotificationHandleType.values[resultType];
  }

  /// 是否是我的好友
  static Future<bool> isMyFriend(String userId) async {
    bool isMyFriend =
        await _channel.invokeMethod('isMyFriend:', {'userId': userId});
    return isMyFriend;
  }

  /// 更新用户
  static Future<bool> updateUser(String userId, {String alias}) async {
    bool success = await _channel
        .invokeMethod('updateUser:', {'userId': userId, 'alias': alias});
    return success;
  }

  /// 修改个人资料
  /// 3:昵称 4:头像 5:签名 6:性别 7:邮箱 8:生日 具体格式为yyyy-MM-dd 9:手机号 10:扩展字段
  static Future<bool> updateMyInfo(int type, dynamic content) async {
    Map keyMap = {
      3: 'nickName',
      4: 'avatarUrl',
      5: 'sign',
      6: 'gender',
      7: 'email',
      8: 'birth',
      9: 'phone',
      10: 'ext'
    };
    bool success = await _channel
        .invokeMethod('updateMyInfo:', {'tag': type, keyMap[type]: content});
    return success;
  }
}
