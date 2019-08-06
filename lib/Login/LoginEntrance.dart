/**
 *  Created by chenyn on 2019-08-06
 *  登录入口
 */

import 'package:flutter/material.dart';
import 'package:cajian/Session/SessionList.dart';
import 'package:cajian/Contacts/Contacts.dart';
import 'package:cajian/Mine/Mine.dart';
import 'package:flutter/services.dart';
import 'Login.dart';
import 'package:cajian/Base/NIMSDKBridge.dart';
import 'package:cajian/Base/NotificationCenter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final List<Widget> _rootWidgets = <Widget>[
  // 会话列表
  new SessionListWidget(),
  // 通讯录
  new ContactsWidget(),
  // 我的
  new MineWidget(),
];

class LoginEntrance extends StatefulWidget {
  final String channelName;

  LoginEntrance({this.channelName});

  LoginEntranceState createState() {
    return new LoginEntranceState();
  }
}

class LoginEntranceState extends State<LoginEntrance> {
  int _selectedIndex = 0;
  bool _logined = false;
  MethodChannel _platform;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    
    
    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
    
    
    // LoginManager().registerWeChat('wx0f56e7c5e6daa01a');
    NotificationCenter.shared.addObserver('loginSuccess', (object){
      debugPrint('did observe notification loginSuccess');
      _loginedSuccess();
    });

    NotificationCenter.shared.addObserver('didLogout', (object){
      debugPrint('did observe notification didLogout');
      _logout();
    });

    // 加载登录状态
    SharedPreferences.getInstance().then((sp){
      String accid = sp.getString('accid');
      String token = sp.getString('token');
      if(accid != null && token != null) 
      {
        _loginedSuccess();
        NIMSDKBridge.autoLogin(accid, token, '');
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
    NotificationCenter.shared.removeObserver('loginSuccess');
    NotificationCenter.shared.removeObserver('didLogout');
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 登录成功
  void _loginedSuccess() {
    setState(() {
      _logined = true;
    });
  }

  // 登出
  void _logout() {
    setState(() {
      _selectedIndex = 0;
      _logined = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _platform.invokeListMethod('页面开始渲染');
    var home = _logined? DefaultTabController(
          length: 3,
          child: new Scaffold(
            body: Center(
              child: _rootWidgets.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  title: Text('擦肩'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  title: Text('通讯录'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text('我'),
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ) : LoginWidget();

    return new MaterialApp(
      home: home,
    );
  }
}