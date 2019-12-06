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

  SessioninfoState _previousState;

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
        bool notifyForNewMsg = await NimSdkUtil.isNotifyForNewMsg(session);

        _previousState = P2PSessionInfoLoaded(
            info: info,
            isStickedOnTop: isStickOnTop,
            notifyStatus: notifyForNewMsg);
        yield _previousState;
      } else {
        /// 加载群数据
        TeamInfo teamInfo = await NimSdkUtil.teamInfoById(session.id);
        String userId = await LoginManager().getAccid();
        /* 置顶 */
        bool isStickOnTop = await NimSdkUtil.isStickedOnTop(session);
        /* 消息通知 */
        bool notifyForNewMsg = await NimSdkUtil.isNotifyForNewMsg(session);

        /// 当前用户的信息
        TeamMemberInfo memberInfo =
            await NimSdkUtil.teamMemberInfoById(session.id, userId);

        ///
        List<UserInfo> infos = await memberInfos();

        _previousState = TeamSessionInfoLoaded(
            info: teamInfo,
            members: infos,
            memberInfo: memberInfo,
            isStickOnTop: isStickOnTop,
            msgNotify: notifyForNewMsg);
        yield _previousState;
      }
    }

    /// 获取群成员
    if (event is FetchMemberInfos) {
      List<UserInfo> infos = await memberInfos();

      TeamSessionInfoLoaded p = _previousState;
      _previousState = TeamSessionInfoLoaded(
            info: p.info,
            members: infos,
            memberInfo: p.memberInfo,
            isStickOnTop: p.isStickOnTop,
            msgNotify: p.msgNotify);
      yield _previousState;
    }

    if (event is SwitchStickOnTopStatus) {
      /* 切换置顶开关 */
      bool newValue = event.newValue;
      NimSdkUtil.stickSessinOnTop(session, newValue);

      if (session.type == 0) {
        P2PSessionInfoLoaded p = _previousState;
        _previousState = P2PSessionInfoLoaded(
            info: p.info,
            isStickedOnTop: newValue,
            notifyStatus: p.notifyStatus);
      } else {
        /// 群
        TeamSessionInfoLoaded p = _previousState;
        _previousState = TeamSessionInfoLoaded(
            info: p.info,
            members: p.members,
            memberInfo: p.memberInfo,
            isStickOnTop: newValue,
            msgNotify: p.msgNotify);
      }
      yield _previousState;
    }

    if (event is SwitchNotifyStatus) {
      /* 开关消息通知 */
      bool newValue = event.newValue;
      print('new Value: $newValue');
      bool success = await NimSdkUtil.changeNotifyStatus(session, newValue);

      if (success) {
        if (session.type == 0) {
          P2PSessionInfoLoaded p = _previousState;
          _previousState = P2PSessionInfoLoaded(
              info: p.info,
              isStickedOnTop: p.isStickedOnTop,
              notifyStatus: newValue);
        } else {
          /// 群
          TeamSessionInfoLoaded p = _previousState;
          _previousState = TeamSessionInfoLoaded(
              info: p.info,
              members: p.members,
              memberInfo: p.memberInfo,
              isStickOnTop: p.isStickOnTop,
              msgNotify: newValue);
        }
        yield _previousState;
      }
    }

    if (event is TappedUserAvatar) {
      String userId = session.id;
      /* 跳转个人信息页 */
      FlutterBoost.singleton.open('user_info',
          urlParams: {'user_id': userId}, exts: {'animated': true});
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

    if (event is QuitTeamEvent) {
      /// 退群
      bool success = await NimSdkUtil.quitTeam(session.id);
      if (success)
        FlutterBoost.singleton.channel.sendEvent('popToRootPage', null);
    }

    if (event is DismissTeamEvent) {
      /// 解散群聊
      bool success = await NimSdkUtil.dismissTeam(session.id);
      if (success)
        FlutterBoost.singleton.channel.sendEvent('popToRootPage', null);
    }

    if (event is TappedTeamMemberAvatarEvent) {
      /// 点击了群成员头像,跳转群成员信息页
      FlutterBoost.singleton.open('member_info',
          urlParams: {'team_id': event.teamId, 'member_id': event.memberId},
          exts: {'animated': true});
    }

    if (event is TappedTeamQrCode) {
      /// 跳转群二维码页面
      FlutterBoost.singleton.open('qrcode', urlParams: {
        'title': '群二维码',
        'content': event.contentStr,
        'embeddedImgAssetPath': event.embeddedImgAssetPath,
        'embeddedImgStyle': event.embeddedImgSize
      }, exts: {
        'animated': true
      });
    }

    if (event is ShowAllMembersEvent) {
      /// 查看全部群成员
      FlutterBoost.singleton
          .open('member_list', urlParams: {}, exts: {'animated': true});
    }
  }

  Future<List<UserInfo>> memberInfos() async {
    /// 获取群成员
    List<TeamMemberInfo> members = await NimSdkUtil.teamMemberInfos(session.id);
    List<UserInfo> infos = [];

    List<Future<UserInfo>> mapFutures = members
        .map((f) async => await NimSdkUtil.userInfoById(userId: f.userId))
        .toList();

    infos = await Future.wait(mapFutures);
    return infos;
  }
}
