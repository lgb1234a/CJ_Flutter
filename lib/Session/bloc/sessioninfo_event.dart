import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';

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
  final bool newValue;
  SwitchNotifyStatus({@required this.newValue});
}

class SwitchStickOnTopStatus extends SessioninfoEvent {
  final bool newValue;
  SwitchStickOnTopStatus({@required this.newValue});
}

class ClearChatHistory extends SessioninfoEvent {}

/* team */
