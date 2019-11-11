/**
 *  Created by chenyn on 2019-06-28
 *  入口
 */
import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'package:bloc/bloc.dart';
import 'Contacts/UserInfo/UserInfoPage.dart';
import 'Contacts/ContactSetting/ContactSetting.dart';

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
      return new SessionInfoWidget(params, cn);
    case 'user_info':
      // 个人信息页
      return new UserInfoPage(params, cn);
    case 'contact_setting':
      // 联系人设置
      return new ContactSetting(params, cn);
    default:
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text('未找到route为: $route 的页面')),
        ),
      );
  }
}

/** 检测擦肩bloc数据流向 */
class CJBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}

void main() {
  BlocSupervisor.delegate = CJBlocDelegate();
  runApp(_widgetForRoute(ui.window.defaultRouteName));
}
