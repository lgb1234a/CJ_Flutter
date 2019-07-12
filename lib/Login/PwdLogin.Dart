/**
 *  Created by chenyn on 2019-07-12
 *  密码登录
 */

import 'package:flutter/material.dart';

class PwdLoginWidget extends StatefulWidget {
  _pwdLoginState createState() {
    return new _pwdLoginState();
  }
}

class _pwdLoginState extends State<PwdLoginWidget> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      body: new Text('密码登录'),
    );
  }
}