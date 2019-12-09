import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SessioninfoEvent extends Equatable {
  const SessioninfoEvent();

  @override
  List<Object> get props => [];
}

/* p2p */
class Fetch extends SessioninfoEvent {}

class TappedUserAvatar extends SessioninfoEvent {}

class CreateGroupSession extends SessioninfoEvent {}

class SwitchNotifyStatus extends SessioninfoEvent {
  final bool newValue;
  SwitchNotifyStatus({@required this.newValue});
}

class SwitchStickOnTopStatus extends SessioninfoEvent {
  final bool newValue;
  SwitchStickOnTopStatus({@required this.newValue});
}

class ClearChatHistory extends SessioninfoEvent {}

/* team */
class FetchMemberInfos extends SessioninfoEvent {}

class OperateMembersEvent extends SessioninfoEvent {
  /// 1:加人进群，2:踢人
  final int type;
  final List<String> filterIds;
  OperateMembersEvent({@required this.type, @required this.filterIds});
}

class ShowAllMembersEvent extends SessioninfoEvent {}

class QuitTeamEvent extends SessioninfoEvent {}

class DismissTeamEvent extends SessioninfoEvent {}

class TappedTeamMemberAvatarEvent extends SessioninfoEvent {
  final String teamId;
  final String memberId;
  TappedTeamMemberAvatarEvent({@required this.teamId, @required this.memberId});
}

/// 更新群名称
class UpdateTeamName extends SessioninfoEvent {
  final String teamName;
  UpdateTeamName({@required this.teamName});
}

class TappedTeamQrCode extends SessioninfoEvent {
  /// 生成二维码的内容
  final String contentStr;

  /// 内嵌图片路径
  final String embeddedImgAssetPath;

  /// 内嵌图片样式
  final double embeddedImgSize;
  TappedTeamQrCode(
      this.contentStr, this.embeddedImgAssetPath, this.embeddedImgSize);
}

/// 查看群公告
class TappedTeamAnnouncement extends SessioninfoEvent {}

/// 更新群昵称
class UpdateTeamNickName extends SessioninfoEvent {
  final String nickName;
  UpdateTeamNickName({@required this.nickName});
}
