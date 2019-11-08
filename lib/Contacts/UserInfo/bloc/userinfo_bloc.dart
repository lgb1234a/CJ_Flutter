import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './bloc.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class UserinfoBloc extends Bloc<UserinfoEvent, UserinfoState> {

  final MethodChannel mc;
  UserinfoBloc({@required this.mc});

  @override
  UserinfoState get initialState => InitialUserinfoState();

  @override
  Stream<UserinfoState> mapEventToState(
    UserinfoEvent event,
  ) async* {

    if(event is FetchUserInfo) {
      /* 获取用户信息 */
      UserInfo info = await NimSdkUtil.userInfoById(userId: event.userId);
      yield UserInfoLoaded(info: info);
    }

    if(event is TouchedUserAvatar) {
      /* 点击查看头像 */
      
    }

    if(event is TouchedAlias) {
      /* 跳转修改备注页面 */

    }

    if(event is TouchedSendMsg) {
      /* 创建群聊 */
      String userId = event.userId;
      /* 调用native，拉起选择联系人组件,创建群聊 */
      mc.invokeMethod('sendMessage:', [userId]);
    }
  }
}
