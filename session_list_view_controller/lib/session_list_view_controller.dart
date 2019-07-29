import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef void SessionListViewControllerCreatedCallback(SessionListViewController controller);
class SessionListViewController {

  SessionListViewController(int id) {
    channel = MethodChannel('plugins/session_list_$id');
    // channel.setMethodCallHandler(handler);
  }

  MethodChannel channel;
}


class SessionList extends StatefulWidget {
  SessionListState createState() {
    return SessionListState();
  }

  const SessionList({
    Key key,
    this.onSessionListViewControllerCreated,
  }):super(key: key);

  final SessionListViewControllerCreatedCallback onSessionListViewControllerCreated;
}


class SessionListState extends State<SessionList> {

  Widget sessionListWidget(BuildContext context) {
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins/session_list',
        onPlatformViewCreated: (int id){
          _onPlatformViewCreated(id, context);
        },
        creationParams: <String,dynamic>{
          // 传递初始化参数
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text('session_list插件尚不支持$defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id, BuildContext context){
    if(widget.onSessionListViewControllerCreated == null){
      return;
    }
    SessionListViewController vc = SessionListViewController(id);
    widget.onSessionListViewControllerCreated(vc);
  }

  @override
  Widget build(BuildContext context) {
    return sessionListWidget(context);
  }
}