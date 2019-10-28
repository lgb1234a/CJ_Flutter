import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SessioninfoEvent extends Equatable {
  const SessioninfoEvent();

  @override
  List<Object> get props => [];
}

/* p2p */

class FetchUserAvatar extends SessioninfoEvent {}

class TappedUserAvatar extends SessioninfoEvent {}

class CreateGroupSession extends SessioninfoEvent {}

class FetchNotifyStatus extends SessioninfoEvent {}

class SwitchNotifyStatus extends SessioninfoEvent {}

class FetchIsStickOnTopStatus extends SessioninfoEvent {}

class SwitchStickOnTopStatus extends SessioninfoEvent {}

/* team */

