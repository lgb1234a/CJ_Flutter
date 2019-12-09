/// Created by chenyn 2019-12-9
/// 群管理页面

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class TeamManagePage extends StatefulWidget {
  final Map params;
  TeamManagePage({Key key, this.params}) : super(key: key);

  @override
  _TeamManagePageState createState() => _TeamManagePageState();
}

class _TeamManagePageState extends State<TeamManagePage> {
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
            '群管理',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Center(
          child: Text('群管理'),
        ),
      ),
    );
  }
}
