import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

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
  OperateMembersEvent(
      {@required this.type, @required this.filterIds});
}

class ShowAllMembersEvent extends SessioninfoEvent {
  final List<UserInfo> members;
  ShowAllMembersEvent({@required this.members});
}

class QuitTeamEvent extends SessioninfoEvent {}
