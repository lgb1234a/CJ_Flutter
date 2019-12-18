import 'package:meta/meta.dart';

@immutable
abstract class MineinfoEvent {}

/// 加载用户信息
class FetchUserInfo extends MineinfoEvent {}