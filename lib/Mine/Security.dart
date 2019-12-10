/// Created by Chenyn 2019-12-10
/// 安全

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class SecurityPage extends StatelessWidget {
  const SecurityPage({Key key}) : super(key: key);

  /// cell
  Widget _cell(Widget title, Widget accessoryView, Function onTap,
      {Widget subTitle}) {
    List<Widget> ws = subTitle == null ? [title] : [title, subTitle];

    double indent = 12;
    return new GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: indent),
        constraints: BoxConstraints(minHeight: 46),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ws,
              ),
            ),
            Container(child: accessoryView),
          ],
        ),
      ),
    );
  }

  /// 密码设置
  Widget _pwdSetting() {
    return _cell(Text('设置登录密码'), Icon(Icons.arrow_forward_ios),
        () => FlutterBoost.singleton.open('pwd_setting', exts: {'animated': true}));
  }

  /// 忘记密码
  Widget _pwdForgot() {
    return _cell(Text('找回密码'), Icon(Icons.arrow_forward_ios),
        () => FlutterBoost.singleton.open('pwd_forgot', exts: {'animated': true}));
  }

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
            '安全',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          children: <Widget>[
            _pwdSetting(),
            Container(
              height: 8,
            ),
            _pwdForgot()
          ],
        ),
      ),
    );
  }
}
