/**
 *  Created by chenyn on 2019-06-28
 *  入口
 */
import 'package:flutter/material.dart';
import 'Contacts/ContactSearching/ContactsSearching.dart';
import 'Login/LoginEntrance.dart';
import 'package:cajian/Mine/Mine.dart';
import 'package:cajian/Contacts/Contacts.dart';
import 'package:cajian/Mine/Setting.dart';
import 'package:cajian/Mine/MineInfo.dart';
import 'package:cajian/Contacts/ContactSearchResult/ContactsSearchResultList.dart';
import 'Session/SessionInfo.dart';
import 'package:bloc/bloc.dart';
import 'Contacts/UserInfo/UserInfoPage.dart';
import 'Contacts/ContactSetting/ContactSetting.dart';
import 'package:flutter_boost/flutter_boost.dart';

/* 检测擦肩bloc数据流向 */
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
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FlutterBoost.singleton.registerPageBuilders({
      'login_entrance': (pageName, params, _) => LoginEntrance(),
      'mine': (pageName, params, _) => MineWidget(),
      'contacts': (pageName, params, _) => ContactsWidget(params),
      'setting': (pageName, params, _) => SettingWidget(),
      'mine_info': (pageName, params, _) => MineInfoWiget(),
      'contact_searching': (pageName, params, _) => ContactsSearchingWidget(),
      'contact_search_result': (pageName, params, _) => ContactsSearchResultListWidget(params),
      'session_info': (pageName, params, _) => SessionInfoWidget(params),
      'user_info': (pageName, params, _) => UserInfoPage(params),
      'contact_setting': (pageName, params, _) => ContactSetting(params),
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: FlutterBoost.init(postPush: _onRoutePushed),
        home: Container());
  }

  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {
  }
}
