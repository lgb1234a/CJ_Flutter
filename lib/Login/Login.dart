/**
 *  Created by chenyn on 2019-07-10
 *  登录
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'LoginManager.dart';
import 'PhoneLogin.dart';
import 'PwdLogin.dart';

class LoginWidget extends StatefulWidget {

  _loginState createState() {
      return new _loginState();
  }
}

class _loginState extends State<LoginWidget> {

  @override 
  Widget build(BuildContext context) {

      Size screenSize = getSize(context);
      return new Scaffold(
        body: new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Positioned.fill(
              child: new Image.asset(
                'images/login_bg@2x.png', 
                fit: BoxFit.fill
              )
            ),
            new Positioned(
              top: 64,
              left: 0,
              right: 0,
              child: new Image.asset(
                  'images/login_logo_cajian@2x.png'
              ),
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new FlatButton(
                  child: new Image.asset('images/login_with_wechat@2x.png'),
                  onPressed: () {
                    // 微信登录
                    LoginManager().getAccessWeChatToken();
                  },
                ),
                new Padding(
                  padding: new EdgeInsets.symmetric(vertical: 20),
                ),
                new Text('其他方式登录', style: new TextStyle(color: Colors.white, fontSize: 12)),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new GestureDetector(
                      child: new Column(
                        children: <Widget>[
                          new Image.asset('images/login_with_phone@2x.png'),
                          new Text('手机登录', style: new TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, new MaterialPageRoute(builder:
                          (BuildContext context) {
                            return PhoneLoginWidget();
                          }
                        ));
                      },
                    ),
                    new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 64),
                    ),
                    new GestureDetector(
                      child: new Column(
                        children: <Widget>[
                          new Image.asset('images/login_with_pwd@2x.png'),
                          new Text('密码登录', style: new TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, new MaterialPageRoute(builder:
                          (BuildContext context) {
                            return PwdLoginWidget();
                          }
                        ));
                      },
                    )
                  ],
                ),
                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 44),
                ),
                new Text('点击登录并继续表示已阅读并同意', style: new TextStyle(color: Colors.white, fontSize: 12)),
                new MaterialButton(
                  child: Text(
                    '《用户使用协议》', 
                    style: new TextStyle(color: Colors.blueGrey, fontSize: 12)
                  ),
                  onPressed: (){},
                )
              ],
            )
          ],
        ),
      );
  }
}