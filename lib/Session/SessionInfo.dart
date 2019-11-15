/**
 * Created by chenyn on 2019-10-21
 * 聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cajian/Session/bloc/bloc.dart';
import './SessionP2PInfo.dart';

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

  @override
  void initState() {
    super.initState();
    _session = Session.fromJson(widget.params);
  }

  // 点对点聊天的会话信息页
  Widget p2pSessionInfo() {
    return BlocProvider<SessioninfoBloc>(
      builder: (context) =>
          SessioninfoBloc()..add(Fetch(session: _session)),
      child: SessionP2PInfo(_session),
    );
  }

  // 群聊天的会话信息页
  Widget teamSessionInfo() {
    return Scaffold(
      body: Center(child: Text('群聊天的会话信息页')),
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
