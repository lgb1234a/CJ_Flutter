import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class UserinfoState {}

class InitialUserinfoState extends UserinfoState {}

class UserInfoLoaded extends UserinfoState {
  final UserInfo info;
  UserInfoLoaded({@required this.info});
}
