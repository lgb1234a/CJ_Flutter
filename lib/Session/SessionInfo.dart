/**
 * Created by chenyn on 2019-10-21
 * 聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:nim_sdk_util/Model/nim_session.dart';

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

    _session = Session(widget.params);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('聊天信息页'),
        ),
      ),
    );
  }
}
