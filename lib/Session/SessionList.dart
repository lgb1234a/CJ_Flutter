/**
 *  Created by chenyn on 2019-06-28
 *  会话列表
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'SessionChat.dart';
import 'package:session_list_view_controller/session_list_view_controller.dart';
import 'package:cajian/Base/CJUtils.dart';

class SessionListWidget extends StatefulWidget {

  SessionListState createState() {
    return new SessionListState();
  }
}

class SessionListState extends State<SessionListWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  BuildContext _context;
  @override
  Widget build(BuildContext context) {
    _context = context;
    return new Scaffold(
      appBar: new AppBar(
        title: const Text(
          '擦肩', 
          style: const TextStyle(color: Color(0xFF141414)),
        ),
        backgroundColor: MainBgColor,
        elevation: 0.01,
      ),
      body: SessionList(onSessionListViewControllerCreated: onSessionListViewCreated,),
    );
  }

  onSessionListViewCreated(SessionListViewController controller) {
    controller.channel.setMethodCallHandler(handler);
  }

  Future<dynamic> handler(MethodCall call) async {
    debugPrint('Native call: '+ call.method + call.arguments.toString());
    
    if(call.method == 'push_session') {
      Navigator.push(_context, MaterialPageRoute(builder: (BuildContext context){
        return SessionChatWidget(call.arguments['session_id'], call.arguments['session_type']);
      }));
    }
  }
}

