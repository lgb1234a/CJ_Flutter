import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

typedef void SessionViewControllerCreatedCallback(SessionViewController controller);
class SessionViewController {
  SessionViewController._(int id)
      : channel = MethodChannel('plugins/session_$id');

  final MethodChannel channel;
}


class Session extends StatefulWidget {
  final String sessionId;
  final int sessionType;

  SessionState createState() {
    return SessionState();
  }

  const Session(
    this.sessionId, 
    this.sessionType, 
  {
    Key key,
    this.onSessionViewControllerCreated
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
          'session_id': widget.sessionId,
          'session_type': widget.sessionType
        },
        creationParamsCodec: new StandardMessageCodec(),
      );
    }
    return Text('session插件尚不支持$defaultTargetPlatform ');
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