import 'package:meta/meta.dart';
@immutable
abstract class UserinfoEvent {}

class FetchUserInfo extends UserinfoEvent{
  final String userId;
  FetchUserInfo({@required this.userId});
}

/* 点击头像 */
class TouchedUserAvatar extends UserinfoEvent {
  
}

/* 点击备注 */
class TouchedAlias extends UserinfoEvent {
  final String alias;
  TouchedAlias({this.alias});
}

/* 点击发送消息 */
class TouchedSendMsg extends UserinfoEvent{
  final String userId;
  TouchedSendMsg({@required this.userId});
}

/* 点击了更多 */
class TouchedMore extends UserinfoEvent {
  final String userId;
  TouchedMore({@required this.userId});
}