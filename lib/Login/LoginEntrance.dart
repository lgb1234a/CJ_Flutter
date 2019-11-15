/**
 *  Created by chenyn on 2019-08-06
 *  登录入口
 */

import 'package:flutter/material.dart';
import 'Login.dart';

class LoginEntrance extends StatefulWidget {
  LoginEntranceState createState() {
    return new LoginEntranceState();
  }
}

class LoginEntranceState extends State<LoginEntrance> {
  @override
  void initState() {
    super.initState();
  }

  @override
  didUpdateWidget(LoginEntrance old) {
    super.didUpdateWidget(old);
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var home = LoginWidget();

    return new MaterialApp(
      home: home,
    );
  }
}