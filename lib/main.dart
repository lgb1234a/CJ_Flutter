/**
 *  Created by chenyn on 2019-06-28
 *  入口
 */
import 'package:flutter/material.dart';
import 'Contacts/ContactSearching/ContactsSearching.dart';
import 'Login/Login.dart';
import 'package:cajian/Login/PhoneLogin.Dart';
import 'package:cajian/Login/PwdLogin.Dart';
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
import 'Login/Register/Register.dart';
import 'Session/SessionMemberInfo.dart';
import 'Components/QrCodePage.dart';
import 'Session/SessionMemberList.dart';
import 'Session/TeamAnnouncement.dart';
import 'Session/TeamManage/TeamManage.dart';
import 'Components/CJWebView.dart';
import 'Mine/Security.dart';
import 'Login/PwdSetting.dart';
import 'Login/PwdForgot.dart';
import 'Mine/BlockList.dart';
import 'Login/PhoneBind.dart';
import 'Mine/QrScan.dart';
import 'Contacts/NewFriends.dart';
import 'Contacts/GroupChat.dart';
import 'Components/CJTeamJoinVerify.dart';


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
      /// 注册页
      'register': (pageName, params, _) => RegisterWidget(),
      /// 登录入口
      'login': (pageName, params, _) => LoginWidget(),
      /// 验证码登录页
      'phone_login': (pageName, params, _) => PhoneLoginWidget(),
      /// 密码登录页
      'pwd_login': (pageName, params, _) => PwdLoginWidget(),
      /// 我
      'mine': (pageName, params, _) => MineWidget(params),
      /// 联系人
      'contacts': (pageName, params, _) => ContactsWidget(params),
      /// 设置
      'setting': (pageName, params, _) => SettingWidget(),
      /// 我的个人信息
      'mine_info': (pageName, params, _) => MineInfoWiget(),
      /// 通讯录搜索页
      'contact_searching': (pageName, params, _) => ContactsSearchingWidget(),
      /// 通讯录搜索结果页
      'contact_search_result': (pageName, params, _) =>
          ContactsSearchResultListWidget(params),
      /// 聊天信息
      'session_info': (pageName, params, _) => SessionInfoWidget(params),
      /// 用户信息
      'user_info': (pageName, params, _) => UserInfoPage(params),
      /// 联系人设置
      'contact_setting': (pageName, params, _) => ContactSetting(params),
      /// 群成员信息
      'member_info': (pageName, params, _) => SessionMemberInfoWidget(params),
      /// 二维码
      'qrcode': (pageName, params, _) => QrCodePage(params: params),
      /// 全部群成员
      'member_list': (pageName, params, _) => SessionMemberListPage(params: params),
      /// 群公告
      'team_announcement': (pageName, params, _) => TeamAnnouncementPage(params: params),
      /// 群管理
      'team_manage': (pageName, params, _) => TeamManagePage(params: params),
      /// webView
      'web_view': (pageName, params, _) => CJWebView(params: params),
      /// 安全
      'security': (pageName, params, _) => SecurityPage(),
      /// 设置登录密码
      'pwd_setting': (pageName, params, _) => PwdSettingPage(params: params,),
      /// 忘记密码
      'pwd_forgot': (pageName, params, _) => PwdForgotPage(params: params,),
      /// 黑名单
      'block_list': (pageName, params, _) => BlockListPage(),
      /// 手机绑定
      'phone_bind': (pageName, params, _) => PhoneBindPage(params: params,),
      /// 扫一扫
      'qr_scan': (pageName, params, _) => QrScanPage(),
      /// 新朋友
      'new_friend': (pageName, params, _) => NewFriendsPage(),
      /// 群聊
      'group_chat': (pageName, params, _) => GroupChatPage(),
      /// 进群验证页面
      'team_join_verify': (pageName, params, _) => CJTeamJoinVerifyPage(params:params)
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: FlutterBoost.init(postPush: _onRoutePushed),
        home: Container());
  }

  void _onRoutePushed(
      String pageName, String uniqueId, Map params, Route route, Future _) {}
}
