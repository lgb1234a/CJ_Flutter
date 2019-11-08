import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/material.dart';

@immutable
abstract class UserinfoState {}

class InitialUserinfoState extends UserinfoState {}

class UserInfoLoaded extends UserinfoState {
  final UserInfo info;
  UserInfoLoaded({@required this.info});
}

class FullScreenAvatar extends UserinfoState {
  final Widget image;
  FullScreenAvatar({@required this.image});
}
