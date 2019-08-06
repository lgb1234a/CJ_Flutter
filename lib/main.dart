/**
 *  Created by chenyn on 2019-06-28
 *  入口
 */

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'Login/LoginEntrance.dart';

Widget _widgetForRoute(String openUrl) 
{
  debugPrint('FlutterViewController openUrl:'+openUrl);
  dynamic initParams = json.decode(openUrl);

  String route = initParams['route'];
  String cn = initParams['channel_name'];
  switch (route) {
    case 'login_entrance':
      return new LoginEntrance(channelName: cn);
    default:
      return Center(child: Text('未找到route为: $route 的页面'));
  }
}


void main() {
  // 注册云信sdk
  // NIMSDKBridge.doRegisterSDK();
  runApp(_widgetForRoute(ui.window.defaultRouteName));
}