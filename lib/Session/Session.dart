/**
 *  Created by chenyn on 2019-06-28
 *  会话列表
 */

import 'package:flutter/material.dart';
import 'SessionChat.dart';

class SessionWidget extends StatefulWidget {

  SessionState createState() {
    return new SessionState();
  }
}

class SessionState extends State<SessionWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {

    final List<String> entries = <String>['A', 'B', 'C'];

    ListView sessionList = ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Text("Row $index")),
          onTap: () {
            setState(() {
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (BuildContext context) {
                    return new SessionChatWidget();
                  })
              );
            });
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );

    return new Scaffold(
      appBar: new AppBar(
        title: const Text(
          '擦肩', 
          style: const TextStyle(color: Color(0xFF141414)),
        ),
        backgroundColor: Color(0xFFECECEC),
        elevation: 0.01,
      ),
      body: sessionList,
    );
  }
}

