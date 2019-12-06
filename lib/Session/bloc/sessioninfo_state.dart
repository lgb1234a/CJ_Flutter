import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class SessioninfoState {
  const SessioninfoState();
}

class InitialSessioninfoState extends SessioninfoState {}

/// 点对点聊天信息加载完成
class P2PSessionInfoLoaded extends SessioninfoState {
  final UserInfo info;
  final bool isStickedOnTop;
  final bool notifyStatus;
  P2PSessionInfoLoaded(
      {@required this.info,
      @required this.isStickedOnTop,
      @required this.notifyStatus});
}

/// 群聊信息加载完成
class TeamSessionInfoLoaded extends SessioninfoState {
  final TeamInfo info;
  final List<UserInfo> members;
  final TeamMemberInfo memberInfo;
  final bool msgNotify;
  final bool isStickOnTop;
  TeamSessionInfoLoaded(
      {@required this.info,
      @required this.memberInfo,
      @required this.msgNotify,
      @required this.isStickOnTop, 
      @required this.members});
}
