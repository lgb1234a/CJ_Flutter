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

  @override
  Stream<SessioninfoState> mapEventToState(
    SessioninfoEvent event,
  ) async* {
    if(event is FetchUserAvatar) {
      UserInfo info = await _fetchUserInfo(event.userId);
      yield UserInfoLoaded(info: info);
    }

    if(event is FetchIsStickOnTopStatus) {
      bool isStickOnTop = await _fetchIsStickOnTop(event.sessionId, event.sessionType);
      yield SessionIsStickedOnTopLoaded(isStickedOnTop: isStickOnTop);
    }


    if(event is FetchNotifyStatus) {
      bool notifyForNewMsg = await _fetchIsNotifyForNewMsg(event.sessionId);
      yield SessionNotifyStatusLoaded(notifyStatus: notifyForNewMsg);
    }

    if(event is CreateGroupSession) {
      /* 创建群聊 */
      String userId = event.userId;
      /* 调用native，拉起选择联系人组件 */
      
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
