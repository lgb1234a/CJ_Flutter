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
import 'package:cajian/Mine/MineInfo.dart';
import 'package:cajian/Contacts/ContactsSearchResultList.dart';
import 'Session/SessionInfo.dart';

Widget _widgetForRoute(String openUrl) {
  debugPrint('FlutterViewController openUrl:' + openUrl);
  dynamic initParams = json.decode(openUrl);

  String route = initParams['route'];
  String cn = initParams['channel_name'];
  Map params = initParams['params'];
  switch (route) {
    case 'login_entrance':
    // 登录入口
      return new LoginEntrance(channelName: cn);
    case 'mine':
    // 我的
      return new MineWidget(cn);
    case 'contacts':
    // 通讯录页
      return new ContactsWidget(params, cn);
    case 'setting':
    // 设置页
      return new SettingWidget(cn);
    case 'mineInfo':
    // 我的信息页
      return new MineInfoWiget(cn);
    case 'contact_search_result':
    // 搜索通讯录结果页
      return new ContactsSearchResultListWidget(params, cn);
    case 'session_info':
    // 会话信息页
      return new SessionInfoWidget(params);
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
