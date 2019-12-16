/**
 * Created by chenyn on 2019-10-21
 * 聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cajian/Session/bloc/bloc.dart';
import './SessionP2PInfo.dart';
import './SessionTeamInfo.dart';

class SessionInfoWidget extends StatefulWidget {
  final Map params;
  SessionInfoWidget(this.params);
  @override
  State<StatefulWidget> createState() {
    return SessionInfoState();
  }
}

class SessionInfoState extends State<SessionInfoWidget> {
  Session _session;
  VoidCallback _callBack;
  SessioninfoBloc _bloc;

  @override
  void dispose() {
    _callBack();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _session = Session.fromJson(widget.params);
    _callBack = FlutterBoost.singleton.channel
        .addEventListener('updateTeamMember', (name, arguments) {
      _bloc.add(FetchMemberInfos());
      return;
    });
  }

  // 点对点聊天的会话信息页
  Widget p2pSessionInfo() {
    return BlocProvider<SessioninfoBloc>(
      create: (context) {
        _bloc = SessioninfoBloc(session: _session)..add(Fetch());
        return _bloc;
      },
      child: SessionP2PInfo(),
    );
  }

  // 群聊天的会话信息页
  Widget teamSessionInfo() {
    return BlocProvider<SessioninfoBloc>(
      create: (context) {
        _bloc = SessioninfoBloc(session: _session)
          ..add(Fetch())
          ..add(FetchMemberInfos());
        return _bloc;
      },
      child: SessionTeamInfoWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _session.type == SessionType.P2P.index
          ? p2pSessionInfo()
          : teamSessionInfo(),
    );
  }
}
