import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class UserinfoBloc extends Bloc<UserinfoEvent, UserinfoState> {
  final String userId;
  UserinfoBloc({@required this.userId});

  @override
  UserinfoState get initialState => InitialUserinfoState();

  @override
  Stream<UserinfoState> mapEventToState(
    UserinfoEvent event,
  ) async* {
    if (event is FetchUserInfo) {
      /* 获取用户信息 */
      UserInfo info = await NimSdkUtil.userInfoById(userId: userId);
      yield UserInfoLoaded(info: info);
    }

    if (event is TouchedUserAvatar) {
      /* 点击查看头像 */
      /// TODO:
    }

    if (event is TouchedAlias) {
      /// 修改备注
      bool success = await NimSdkUtil.updateUser(userId, alias: event.alias);
      if(success) add(FetchUserInfo());
    }

    if (event is TouchedSendMsg) {
      /* 调用native，拉起选择联系人组件,创建群聊 */
      FlutterBoost.singleton.open(
          'nativePage://androidPageName=com.youxi.chat.module.session.SessionHelper&iosPageName=CJSessionViewController',
          urlParams: {'id': userId, 'type': 0},
          exts: {'animated': true});
    }

    if (event is TouchedMore) {
      /* 跳转个人信息设置页 */
      FlutterBoost.singleton.open('contact_setting',
          urlParams: {'userId': userId}, exts: {'animated': true});
    }
  }
}
