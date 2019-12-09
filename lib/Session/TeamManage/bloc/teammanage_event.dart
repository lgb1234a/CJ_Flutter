import 'package:meta/meta.dart';

@immutable
abstract class TeammanageEvent {}

/// 获取数据
class Fetch extends TeammanageEvent {}

/// 群机器人
class TappedToRobotSetting extends TeammanageEvent {}