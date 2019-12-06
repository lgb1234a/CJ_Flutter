/// Created by chenyn 2019-12-6
/// 群成员列表

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class SessionMemberListPage extends StatefulWidget {
  final Map params;
  SessionMemberListPage({Key key, @required this.params}) : super(key: key);

  @override
  _SessionMemberListPageState createState() => _SessionMemberListPageState();
}

class _SessionMemberListPageState extends State<SessionMemberListPage> {
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
            '群成员',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          child: Center(
            child: Text('群成员列表'),
          ),
        ),
      ),
    );
  }
}
