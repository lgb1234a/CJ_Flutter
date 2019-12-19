import 'package:meta/meta.dart';

@immutable
abstract class MineinfoEvent {}

/// 加载用户信息
class FetchUserInfo extends MineinfoEvent {}

/// 替换头像
class TappedAvatar extends MineinfoEvent {
  final int type;
  TappedAvatar({@required this.type});
}

/// 修改昵称
class UpdateNickName extends MineinfoEvent {
  final String name;
  UpdateNickName({@required this.name});
}

/// 修改邮箱
class UpdateEmail extends MineinfoEvent {
  final String email;
  UpdateEmail({@required this.email});
}

/// 修改签名
class UpdateSign extends MineinfoEvent {
  final String sign;
  UpdateSign({@required this.sign});
}