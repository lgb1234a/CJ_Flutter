/// Created by Chenyn 2019-12-10
/// 忘记密码

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class PwdForgotPage extends StatefulWidget {
  PwdForgotPage({Key key}) : super(key: key);

  @override
  _PwdForgotPageState createState() => _PwdForgotPageState();
}

class _PwdForgotPageState extends State<PwdForgotPage> {
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
            '忘记密码',
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