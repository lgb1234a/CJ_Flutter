import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef void SessionViewControllerCreatedCallback(SessionViewController controller);
class SessionViewController {
  SessionViewController._(int id)
      : _channel = MethodChannel('plugins/session_$id');

  final MethodChannel _channel;

  Future<void> start() async {
    return _channel.invokeMethod('start');
  }

  Future<void> stop() async {
    return _channel.invokeMethod('stop');
  }
}


class Session extends StatefulWidget {
  SessionState createState() {
    return SessionState();
  }

  const Session({
    Key key,
    this.onSessionViewControllerCreated,
  }):super(key: key);

  final SessionViewControllerCreatedCallback onSessionViewControllerCreated;
}


class SessionState extends State<Session> {

  Widget sessionWidget() {
    if(defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: 'plugins/session',
        onPlatformViewCreated: _onPlatformViewCreated,
        creationParams: <String,dynamic>{
          // 传递初始化参数
          'session_id': '',
          'session_type': 1
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text('activity_indicator插件尚不支持$defaultTargetPlatform ');
  }

  void _onPlatformViewCreated(int id){
    if(widget.onSessionViewControllerCreated == null){
      return;
    }
    widget.onSessionViewControllerCreated(new SessionViewController._(id));
  }

  @override
  Widget build(BuildContext context) {
    return sessionWidget();
  }
}