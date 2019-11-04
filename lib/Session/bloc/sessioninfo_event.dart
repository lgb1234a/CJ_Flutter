import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SessioninfoEvent extends Equatable {
  const SessioninfoEvent();

  @override
  List<Object> get props => [];
}

/* p2p */

class FetchUserAvatar extends SessioninfoEvent {
  final String userId;
  FetchUserAvatar({@required this.userId});
}

class TappedUserAvatar extends SessioninfoEvent {}

class CreateGroupSession extends SessioninfoEvent {
  final String userId; // 点对点聊天，对方的id
  CreateGroupSession({@required this.userId});
}

class FetchNotifyStatus extends SessioninfoEvent {
  final String sessionId;
  FetchNotifyStatus({@required this.sessionId});
}

class SwitchNotifyStatus extends SessioninfoEvent {}

class FetchIsStickOnTopStatus extends SessioninfoEvent {
  final String sessionId;
  final int sessionType;
  FetchIsStickOnTopStatus(
      {@required this.sessionId, @required this.sessionType});
}

class SwitchStickOnTopStatus extends SessioninfoEvent {}

class ClearChatHistory extends SessioninfoEvent {}

/* team */
