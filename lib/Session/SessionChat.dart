/**
 *  Created by chenyn on 2019-06-28
 */

import 'package:flutter/material.dart';

class SessionChatWidget extends StatefulWidget {

  SessionChatState createState() {
    return new SessionChatState();
  }

}

class SessionChatState extends State<SessionChatWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text(
            'session'
        ),
        backgroundColor: Colors.red,
        elevation: 1,
      ),
      body: new Text(
        '会话界面'
      )
    );
  }
}