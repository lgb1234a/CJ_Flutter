/**
 *  Created by chenyn on 2019-08-06
 *  登录入口
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Login.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginEntrance extends StatefulWidget {
  final String channelName;

  LoginEntrance({this.channelName});

  LoginEntranceState createState() {
    return new LoginEntranceState();
  }
}

class LoginEntranceState extends State<LoginEntrance> {
  MethodChannel _platform;

  @override
  void initState() {
    super.initState();
    
    
    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);

    // 加载登录状态
    SharedPreferences.getInstance().then((sp){
      String accid = sp.getString('accid');
      String token = sp.getString('token');
      if(accid != null && token != null) 
      {
        NimSdkUtil.autoLogin(accid, token, '');
      }
    });
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
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
    var home = LoginWidget(_platform);

    return new MaterialApp(
      home: home,
    );
  }
}