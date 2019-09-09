/**
 *  Created by chenyn on 2019-06-28
 *  入口
 */

import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'Login/LoginEntrance.dart';
import 'package:cajian/Mine/Mine.dart';
import 'package:cajian/Contacts/Contacts.dart';
import 'package:cajian/Mine/Setting.dart';

Widget _widgetForRoute(String openUrl) {
  debugPrint('FlutterViewController openUrl:' + openUrl);
  dynamic initParams = json.decode(openUrl);

  String route = initParams['route'];
  String cn = initParams['channel_name'];
  Map params = initParams['params'];
  switch (route) {
    case 'login_entrance':
      return new LoginEntrance(channelName: cn);
    case 'mine':
      return new MineWidget(cn);
    case 'contacts':
      return new ContactsWidget(params);
    case 'setting':
      return new SettingWidget(cn);
    default:
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('未找到route为: $route 的页面')),
        ),
      );
  }
}

void main() {
  runApp(_widgetForRoute(ui.window.defaultRouteName));
}
