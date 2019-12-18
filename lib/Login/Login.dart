///
///  Created by chenyn on 2019-07-10
///  登录
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wx_sdk/wx_sdk.dart';
import 'package:flutter_boost/flutter_boost.dart';

class LoginWidget extends StatefulWidget {
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<LoginWidget> {
  wxlogin() {
    WxSdk.wxLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
              child: Image.asset('images/login_bg@2x.png', fit: BoxFit.fill)),
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Image.asset('images/login_logo_cajian@2x.png'),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CupertinoButton(
                child: Image.asset('images/login_with_wechat@2x.png'),
                onPressed: () {
                  // 微信登录
                  wxlogin();
                },
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Text('其他方式登录',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Image.asset('images/login_with_phone@2x.png'),
                        Text('手机登录',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    onTap: () {
                      FlutterBoost.singleton
                          .open('phone_login', exts: {'animated': true});
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 64),
                  ),
                  GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Image.asset('images/login_with_pwd@2x.png'),
                        Text('密码登录',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    onTap: () {
                      FlutterBoost.singleton
                          .open('pwd_login', exts: {'animated': true});
                    },
                  )
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
              ),
              Text('点击登录并继续表示已阅读并同意',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              CupertinoButton(
                child: Text('《用户使用协议》',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                onPressed: () => FlutterBoost.singleton.open('web_view',
                    urlParams: {
                      'url': 'https://help.youxi2018.cn/agreement/user.html',
                      'title': '用户使用协议'
                    },
                    exts: {
                      'animated': true
                    }),
              )
            ],
          )
        ],
      ),
    ));
  }
}
