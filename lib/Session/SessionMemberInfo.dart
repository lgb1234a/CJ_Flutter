/// Created by chenyn 2019-11-27
/// 群成员信息页

import 'package:flutter/material.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';

class SessionMemberInfoWidget extends StatefulWidget {
  final Map params;
  SessionMemberInfoWidget(this.params);

  @override
  State<StatefulWidget> createState() {
    return SessionMemberInfoState();
  }
}

class SessionMemberInfoState extends State<SessionMemberInfoWidget> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '成员信息',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Center(
          child: Text('群成员信息页'),
        ),
      ),
    );
  }
}
