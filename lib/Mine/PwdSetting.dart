/// Created by Chenyn 2019-12-10
/// 设置密码

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class PwdSettingPage extends StatefulWidget {
  PwdSettingPage({Key key}) : super(key: key);

  @override
  _PwdSettingPageState createState() => _PwdSettingPageState();
}

class _PwdSettingPageState extends State<PwdSettingPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '设置登录密码',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(children: <Widget>[

        ],),
      ),
    );
  }
}