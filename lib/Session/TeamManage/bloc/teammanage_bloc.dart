import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class TeammanageBloc extends Bloc<TeammanageEvent, TeammanageState> {
  final String teamId;
  TeammanageBloc({@required this.teamId});

  @override
  TeammanageState get initialState => InitialTeammanageState();

  DataLoaded previousState;
  @override
  Stream<TeammanageState> mapEventToState(
    TeammanageEvent event,
  ) async* {
    if (event is Fetch) {
      /// 获取数据
      List<TeamMemberInfo> members = await NimSdkUtil.teamMemberInfos(teamId);
      List managerIds = members
          .where((m) {
            return m.type == 2;
          })
          .toList()
          .map((f) => f.userId)
          .toList();

      
      previousState = DataLoaded(managers: managerIds);
      yield previousState;
    }

    if(event is TappedToRobotSetting) {
      /// 群机器人页面
      FlutterBoost.singleton.open('');
    }
  }
}
