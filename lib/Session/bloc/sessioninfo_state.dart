import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class SessioninfoState{
  const SessioninfoState();
}
  
class InitialSessioninfoState extends SessioninfoState {}

class UserInfoLoaded extends SessioninfoState {
  final UserInfo info;
  UserInfoLoaded({@required this.info});
}

class SessionIsStickedOnTopLoaded extends SessioninfoState {
  final bool isStickedOnTop;
  SessionIsStickedOnTopLoaded({@required this.isStickedOnTop});
}

class SessionNotifyStatusLoaded extends SessioninfoState {
  final bool notifyStatus;
  SessionNotifyStatusLoaded({@required this.notifyStatus});
}
