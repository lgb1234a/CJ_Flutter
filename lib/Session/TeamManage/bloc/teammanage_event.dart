import 'package:meta/meta.dart';

@immutable
abstract class TeammanageEvent {}

/// 获取数据
class Fetch extends TeammanageEvent {}

/// 群机器人
class TappedToRobotSetting extends TeammanageEvent {}

/// 群转让
class TeamTransform extends TeammanageEvent {}

/// 群管理员设置
class TeamManagerSetting extends TeammanageEvent {}