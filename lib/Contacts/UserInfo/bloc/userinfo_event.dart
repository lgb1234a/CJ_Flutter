import 'package:meta/meta.dart';

@immutable
abstract class UserinfoEvent {}

class FetchUserInfo extends UserinfoEvent{
  final String userId;
  FetchUserInfo({@required this.userId});
}

/* 点击头像 */
class TouchedUserAvatar extends UserinfoEvent {}

/* 点击备注 */
class TouchedAlias extends UserinfoEvent {}

/* 点击更多 */
class TouchedMore extends UserinfoEvent {}

/* 点击发送消息 */
class TouchedSendMsg extends UserinfoEvent{}

/* 点击右上角省略号 */
class TouchedEllipsis extends UserinfoEvent {}