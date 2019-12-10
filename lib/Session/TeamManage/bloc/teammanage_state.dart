import 'package:meta/meta.dart';

@immutable
abstract class TeammanageState {}
  
class InitialTeammanageState extends TeammanageState {}

/// 加载完成
class DataLoaded extends TeammanageState {
  final List<String> managers;
  DataLoaded({@required this.managers});
}