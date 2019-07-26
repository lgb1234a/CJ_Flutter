import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef void SessionListViewControllerCreatedCallback(SessionListViewController controller);
class SessionListViewController {
  SessionListViewController._(int id)
      : _channel = MethodChannel('plugins/session_list_$id');

  final MethodChannel _channel;

  Future<void> start() async {
    return _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    return _channel.invokeMethod('stop');
  }
}


class SessionList extends StatefulWidget {
  SessionState createState() {
    return SessionState();
  }

  const SessionList({
    Key key,
    this.onSessionListViewControllerCreated,
  }):super(key: key);

  final SessionListViewControllerCreatedCallback onSessionListViewControllerCreated;
}


class SessionState extends State<SessionList> {

  Widget sessionListWidget() {
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins/session_list',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String,dynamic>{
          // 传递初始化参数
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text('activity_indicator插件尚不支持$defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id){
    if(widget.onSessionListViewControllerCreated == null){
      return;
    }
    widget.onSessionListViewControllerCreated(new SessionListViewController._(id));
  }

  @override
  Widget build(BuildContext context) {
    return sessionListWidget();
  }
}