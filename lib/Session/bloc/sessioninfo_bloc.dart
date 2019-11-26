/**
 * Created by chenyn 2019-10-27
 * 聊天信息页的bloc信息流处理类
 */

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import '../../Login/LoginManager.dart';

class SessioninfoBloc extends Bloc<SessioninfoEvent, SessioninfoState> {
  final Session session;
  SessioninfoBloc({@required this.session});
  @override
  SessioninfoState get initialState => InitialSessioninfoState();

  P2PSessionInfoLoaded _previousState;

  @override
  Stream<SessioninfoState> mapEventToState(
    SessioninfoEvent event,
  ) async* {
    if (event is Fetch) {
      /// 加载所需的数据
      if (session.type == 0) {
        /* 用户头像、昵称 */
        UserInfo info = await NimSdkUtil.userInfoById(userId: session.id);
        /* 置顶 */
        bool isStickOnTop = await NimSdkUtil.isStickedOnTop(session);
        /* 消息通知 */
        bool notifyForNewMsg = await NimSdkUtil.isNotifyForNewMsg(session.id);

        _previousState = P2PSessionInfoLoaded(
            info: info,
            isStickedOnTop: isStickOnTop,
            notifyStatus: notifyForNewMsg);
        yield _previousState;
      } else {
        /// 加载群数据
        TeamInfo teamInfo = await NimSdkUtil.teamInfoById(session.id);
        String userId = await LoginManager().getAccid();
        /// 当前用户的群成员信息
        TeamMemberInfo memberInfo =
            await NimSdkUtil.teamMemberInfoById(session.id, userId);
        yield TeamSessionInfoLoaded(info: teamInfo, memberInfo: memberInfo);
      }
    }

    /// 获取群成员
    if (event is FetchMemberInfos) {
      List<TeamMemberInfo> members =
          await NimSdkUtil.teamMemberInfos(session.id);
      List<UserInfo> infos = [];

      List<Future<UserInfo>> mapFutures = members
          .map((f) async => await NimSdkUtil.userInfoById(userId: f.userId))
          .toList();

      infos = await Future.wait(mapFutures);
      yield TeamMembersLoaded(members: infos);
    }

    if (event is SwitchStickOnTopStatus) {
      /* 切换置顶开关 */
      bool newValue = event.newValue;
      NimSdkUtil.stickSessiOnTop(session, newValue);

      _previousState = P2PSessionInfoLoaded(
          info: _previousState.info,
          isStickedOnTop: newValue,
          notifyStatus: _previousState.notifyStatus);
      yield _previousState;
    }

    if (event is SwitchNotifyStatus) {
      /* 开关消息通知 */
      bool newValue = event.newValue;
      bool success = await NimSdkUtil.changeNotifyStatus(session, newValue);

      if (success) {
        _previousState = P2PSessionInfoLoaded(
            info: _previousState.info,
            isStickedOnTop: _previousState.isStickedOnTop,
            notifyStatus: newValue);
        yield _previousState;
      }
    }

    if (event is TappedUserAvatar) {
      String userId = session.id;
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
      String userId = session.id;
      /* 调用native，拉起选择联系人组件,创建群聊 */
      FlutterBoost.singleton.channel.sendEvent('createGroupChat', {
        'user_ids': [userId]
      });
    }

    if (event is ClearChatHistory) {
      /* 清空聊天记录 */
      NimSdkUtil.clearChatHistory(session);
    }

    if (event is OperateMembersEvent) {
      /// 操作群成员
      if (event.type == 0) {
        /// 移除
        FlutterBoost.singleton.channel
            .sendEvent('kickUserOutTeam', {'team_id': session.id});
      }

      if (event.type == 1) {
        /// 添加
        FlutterBoost.singleton.channel.sendEvent('addTeamMember',
            {'team_id': session.id, 'filter_ids': event.filterIds});
      }
    }

    if(event is QuitTeamEvent) {
      /// 退群
      await NimSdkUtil.quitTeam(session.id);
    }
  }
}
