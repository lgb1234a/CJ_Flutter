/**
 *  Created by chenyn on 2019-06-28
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:session_list_view_controller/session_view_controller.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Base/NIMSDKBridge.dart';

class SessionChatWidget extends StatefulWidget {
  final String sessionId;
  final int sessionType;
  SessionChatWidget(this.sessionId, this.sessionType);

  SessionChatState createState() {
    return new SessionChatState();
  }
}

class SessionChatState extends State<SessionChatWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  String showName = '';
  @override
  void initState() {
    super.initState();

    widget.sessionType == 0?fetchUserInfo() : fetctTeamInfo();
  }

  fetctTeamInfo() async{
    dynamic _teamInfo = await NIMSDKBridge.teamInfoById(widget.sessionId);
    setState(() {
      showName = _teamInfo['show_name'];
    });
  }

  fetchUserInfo() async {
    dynamic _userInfo = await NIMSDKBridge.userInfoById(widget.sessionId);
    setState(() {
      showName = _userInfo['show_name'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            showName,
            style: TextStyle(color: BlackColor),
        ),
        backgroundColor: MainBgColor,
        iconTheme: IconThemeData.fallback(),
        elevation: 0.01,
      ),
      body: Session(widget.sessionId, widget.sessionType, onSessionViewControllerCreated: onSessionListViewCreated)
    );
  }

  onSessionListViewCreated(SessionViewController controller) {
    controller.channel.setMethodCallHandler(handler);
  }

  // 处理事件
  Future<dynamic> handler(MethodCall call) async {
    debugPrint('Native call: '+ call.method + call.arguments.toString());
    
    // if(call.method == 'push_session') {
    //   Navigator.push(_context, MaterialPageRoute(builder: (BuildContext context){
    //     return SessionChatWidget(call.arguments['session_id'], call.arguments['session_type']);
    //   }));
    // }
  }
}