/**
 * Created by chenyn 2019-10-27
 * 聊天信息页的bloc信息流处理类
 */

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import './bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class SessioninfoBloc extends Bloc<SessioninfoEvent, SessioninfoState> {
  final MethodChannel mc;
  SessioninfoBloc({@required this.mc});

  @override
  SessioninfoState get initialState => InitialSessioninfoState();

  P2PSessionInfoLoaded _previousState;

  @override
  Stream<SessioninfoState> mapEventToState(
    SessioninfoEvent event,
  ) async* {
    if (event is Fetch) {
      // 加载所需的数据
      UserInfo info = await _fetchUserInfo(event.session.id);
      bool isStickOnTop =
          await _fetchIsStickOnTop(event.session.id, event.session.type);
      bool notifyForNewMsg = await _fetchIsNotifyForNewMsg(event.session.id);

      _previousState = P2PSessionInfoLoaded(
          info: info,
          isStickedOnTop: isStickOnTop,
          notifyStatus: notifyForNewMsg);
      yield _previousState;
    }

    if (event is SwitchStickOnTopStatus) {
      /* 切换置顶开关 */
      bool newValue = event.newValue;

      _previousState = P2PSessionInfoLoaded(
          info: _previousState.info,
          isStickedOnTop: newValue,
          notifyStatus: _previousState.notifyStatus);
      yield _previousState;
    }

    if (event is SwitchNotifyStatus) {
      /* 切换消息通知开关 */
      bool newValue = event.newValue;

      _previousState = P2PSessionInfoLoaded(
          info: _previousState.info,
          isStickedOnTop: _previousState.isStickedOnTop,
          notifyStatus: newValue);
      yield _previousState;
    }

    if (event is TappedUserAvatar) {
      String userId = event.userId;
      /* 跳转个人信息页 */
      debugPrint('跳个人信息页：$userId');
    }

    if (event is CreateGroupSession) {
      /* 创建群聊 */
      String userId = event.userId;
      /* 调用native，拉起选择联系人组件 */
      debugPrint('拉起选择联系人');
    }

    if (event is ClearChatHistory) {
      /* 清空聊天记录 */

    }
  }

  // 获取用户信息
  Future<UserInfo> _fetchUserInfo(String userId) async {
    UserInfo info = await NimSdkUtil.userInfoById(userId);
    return info;
  }

  // 获取会话置顶状态
  Future<bool> _fetchIsStickOnTop(String sessionId, int sessionType) async {
    bool isStickOnTop = await NimSdkUtil.isStickedOnTop(sessionId, sessionType);
    return isStickOnTop;
  }

  // 获取会话是否开启消息提醒
  Future<bool> _fetchIsNotifyForNewMsg(String sessionId) async {
    bool isNotifyForNewMsg = await NimSdkUtil.isNotifyForNewMsg(sessionId);
    return isNotifyForNewMsg;
  }
}
