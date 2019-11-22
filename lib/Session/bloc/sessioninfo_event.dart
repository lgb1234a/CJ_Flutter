import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class SessioninfoEvent extends Equatable {
  const SessioninfoEvent();

  @override
  List<Object> get props => [];
}

/* p2p */
class Fetch extends SessioninfoEvent {
  final Session session;
  Fetch({@required this.session});
}

class TappedUserAvatar extends SessioninfoEvent {
  final String userId; // 点对点聊天，对方的id
  TappedUserAvatar({@required this.userId});
}

class CreateGroupSession extends SessioninfoEvent {
  final String userId; // 点对点聊天，对方的id
  CreateGroupSession({@required this.userId});
}

class SwitchNotifyStatus extends SessioninfoEvent {
  final Session session;
  final bool newValue;
  SwitchNotifyStatus({@required this.session, @required this.newValue});
}

class SwitchStickOnTopStatus extends SessioninfoEvent {
  final Session session;
  final bool newValue;
  SwitchStickOnTopStatus({@required this.session, @required this.newValue});
}

class ClearChatHistory extends SessioninfoEvent {
  final Session session;
  ClearChatHistory({@required this.session});
}

/* team */
class FetchMemberInfos extends SessioninfoEvent {
  final Session session;
  FetchMemberInfos({@required this.session});
}

class OperateMembersEvent extends SessioninfoEvent {
  /// 1:加人进群，2:踢人
  final int type;
  OperateMembersEvent({@required this.type});
}

class ShowAllMembersEvent extends SessioninfoEvent {
  final List<UserInfo> members;
  ShowAllMembersEvent({@required this.members});
}