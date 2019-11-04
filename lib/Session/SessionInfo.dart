/**
 * Created by chenyn on 2019-10-21
 * 聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';
import '../Base/CJUtils.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:cajian/Session/bloc/bloc.dart';
import './SessionP2PInfo.dart';

class SessionInfoWidget extends StatefulWidget {
  final Map params;
  final String channelName;
  SessionInfoWidget(this.params, this.channelName);
  @override
  State<StatefulWidget> createState() {
    return SessionInfoState();
  }
}

class SessionInfoState extends State<SessionInfoWidget> {
  Session _session;
  MethodChannel _platform;
  SessioninfoBloc _bloc;

  @override
  void initState() {
    super.initState();

    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
    _session = Session.fromJson(widget.params);
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
  }

  // 点对点聊天的会话信息页
  Widget p2pSessionInfo(BuildContext context) {
    return BlocProvider<SessioninfoBloc>(
      builder: (context) => SessioninfoBloc(mc: _platform)
        ..add(FetchUserAvatar(userId: _session.id))
        ..add(FetchNotifyStatus(sessionId: _session.id))
        ..add(FetchIsStickOnTopStatus(
            sessionId: _session.id, sessionType: _session.type)),
      child: SessionP2PInfo(_session),
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
      home: _session.type == SessionType.P2P.index
          ? p2pSessionInfo(context)
          : teamSessionInfo(context),
    );
  }
}
