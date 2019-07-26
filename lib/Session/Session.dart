/**
 *  Created by chenyn on 2019-06-28
 *  会话列表
 */

import 'package:flutter/material.dart';
import 'SessionChat.dart';
import 'package:session_list_view_controller/session_list_view_controller.dart';

class SessionWidget extends StatefulWidget {

  SessionState createState() {
    return new SessionState();
  }
}

class SessionState extends State<SessionWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: const Text(
          '擦肩', 
          style: const TextStyle(color: Color(0xFF141414)),
        ),
        backgroundColor: Color(0xFFECECEC),
        elevation: 0.01,
      ),
      body: SessionList(),
    );
  }
}

