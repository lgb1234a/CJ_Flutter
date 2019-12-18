import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class MineinfoState {}
  
class InitialMineinfoState extends MineinfoState {}


class UserInfoLoaded extends MineinfoState {
  final UserInfo userInfo;
  UserInfoLoaded({@required this.userInfo});
}