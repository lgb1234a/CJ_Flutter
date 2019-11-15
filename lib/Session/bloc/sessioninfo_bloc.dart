/**
 * Created by chenyn 2019-10-27
 * 聊天信息页的bloc信息流处理类
 */

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class SessioninfoBloc extends Bloc<SessioninfoEvent, SessioninfoState> {
  @override
  SessioninfoState get initialState => InitialSessioninfoState();

  P2PSessionInfoLoaded _previousState;

  @override
  Stream<SessioninfoState> mapEventToState(
    SessioninfoEvent event,
  ) async* {
    if (event is Fetch) {
      // 加载所需的数据
      /* 用户头像、昵称 */
      UserInfo info = await NimSdkUtil.userInfoById(userId: event.session.id);
      /* 置顶 */
      bool isStickOnTop = await NimSdkUtil.isStickedOnTop(event.session);
      /* 消息通知 */
      bool notifyForNewMsg =
          await NimSdkUtil.isNotifyForNewMsg(event.session.id);

      _previousState = P2PSessionInfoLoaded(
          info: info,
          isStickedOnTop: isStickOnTop,
          notifyStatus: notifyForNewMsg);
      yield _previousState;
    }

    if (event is SwitchStickOnTopStatus) {
      /* 切换置顶开关 */
      bool newValue = event.newValue;
      NimSdkUtil.stickSessiOnTop(event.session, newValue);

      _previousState = P2PSessionInfoLoaded(
          info: _previousState.info,
          isStickedOnTop: newValue,
          notifyStatus: _previousState.notifyStatus);
      yield _previousState;
    }

    if (event is SwitchNotifyStatus) {
      /* 开关消息通知 */
      bool newValue = event.newValue;
      bool success =
          await NimSdkUtil.changeNotifyStatus(event.session, newValue);

      if (success) {
        _previousState = P2PSessionInfoLoaded(
            info: _previousState.info,
            isStickedOnTop: _previousState.isStickedOnTop,
            notifyStatus: newValue);
        yield _previousState;
      }
    }

    if (event is TappedUserAvatar) {
      String userId = event.userId;
      /* 跳转个人信息页 */
      FlutterBoost.singleton.open('user_info',
          urlParams: {'user_id': userId},
          exts: {'animated': true}).then((Map value) {
        print(
            "call me when page is finished. did recieve second route result $value");
      });
    }

    if (event is CreateGroupSession) {
      /* 创建群聊 */
      String userId = event.userId;
      /* 调用native，拉起选择联系人组件,创建群聊 */
      FlutterBoost.singleton.channel.sendEvent('createGroupChat', {
        'user_ids': [userId]
      });
    }

    if (event is ClearChatHistory) {
      /* 清空聊天记录 */
      NimSdkUtil.clearChatHistory(event.session);
    }
  }
}
