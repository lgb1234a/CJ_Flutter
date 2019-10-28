/**
 * Created by chenyn on 2019-10-21
 * 聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

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
  final StreamController _streamController = StreamController();
  @override
  void initState() {
    super.initState();

    _session = Session.fromJson(widget.params);
  }

  // 点对点聊天的会话信息页
  Widget p2pSessionInfo(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _streamController.stream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot snapshot){
            return null;
        },
      ),
    );
  }

  // 群聊天的会话信息页
  Widget teamSessionInfo(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('群聊天的会话信息页')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _session.type == SessionType.P2P.index ? p2pSessionInfo(context) : teamSessionInfo(context),
    );
  }
}
