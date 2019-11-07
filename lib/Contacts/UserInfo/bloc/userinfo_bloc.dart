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
      UserInfo info = await NimSdkUtil.userInfoById(event.userId);
      yield UserInfoLoaded(info: info);
    }

    if(event is TouchedUserAvatar) {

    }

    if(event is TouchedAlias) {
      
    }

    if(event is TouchedMore) {
      
    }

    if(event is TouchedSendMsg) {
      
    }

    if(event is TouchedMore) {
      
    }
  }
}
