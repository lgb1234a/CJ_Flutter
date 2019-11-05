import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class SessioninfoState {
  const SessioninfoState();
}

class InitialSessioninfoState extends SessioninfoState {}

class P2PSessionInfoLoaded extends SessioninfoState {
  final UserInfo info;
  final bool isStickedOnTop;
  final bool notifyStatus;
  P2PSessionInfoLoaded(
      {@required this.info,
      @required this.isStickedOnTop,
      @required this.notifyStatus});
}
