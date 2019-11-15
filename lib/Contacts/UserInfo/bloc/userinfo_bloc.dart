import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class UserinfoBloc extends Bloc<UserinfoEvent, UserinfoState> {
  @override
  UserinfoState get initialState => InitialUserinfoState();

  @override
  Stream<UserinfoState> mapEventToState(
    UserinfoEvent event,
  ) async* {
    if (event is FetchUserInfo) {
      /* 获取用户信息 */
      UserInfo info = await NimSdkUtil.userInfoById(userId: event.userId);
      yield UserInfoLoaded(info: info);
    }

    if (event is TouchedUserAvatar) {
      /* 点击查看头像 */

    }

    if (event is TouchedAlias) {
      /* 跳转修改备注页面 */

    }

    if (event is TouchedSendMsg) {
      /* 创建群聊 */
      String userId = event.userId;
      /* 调用native，拉起选择联系人组件,创建群聊 */
      FlutterBoost.singleton.channel
          .sendEvent('sendMessage', {'session_id': userId, 'type': 0});
    }

    if (event is TouchedMore) {
      String userId = event.userId;
      /* 跳转个人信息设置页 */
      FlutterBoost.singleton.open('contact_setting',
          urlParams: {'user_id': userId}, exts: {'animated': true});
    }
  }
}
