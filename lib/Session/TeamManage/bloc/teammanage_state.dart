import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class TeammanageState {}
  
class InitialTeammanageState extends TeammanageState {}

/// 加载完成
class DataLoaded extends TeammanageState {
  final List<String> managers;
  DataLoaded({@required this.managers});
}