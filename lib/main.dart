
/**
 *  Created by chenyn on 2019-06-28
 *  主页
 */

import 'package:flutter/material.dart';
import 'Session/Session.dart';
import 'Contacts/Contacts.dart';
import 'Mine/Mine.dart';
import 'Login/Login.dart';
import 'Login/LoginManager.dart';
import 'Base/NIMSDKBridge.dart';
import 'package:cajian/Base/NotificationCenter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cajian/Base/NIMSDKBridge.dart';

final List<Widget> _rootWidgets = <Widget>[
  // 会话列表
  new SessionWidget(),
  // 通讯录
  new ContactsWidget(),
  // 我的
  new MineWidget(),
];



class CajianWidget extends StatefulWidget {
  _CajianState createState() {
    return new _CajianState();
  }
}

class _CajianState extends State<CajianWidget> {
  int _selectedIndex = 0;
  bool _logined = false;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();

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

  @override
  didUpdateWidget(CajianWidget old) {
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

  void _loginedSuccess() {
    setState(() {
      _logined = true;
    });
  }

  void _logout() {
    setState(() {
      _selectedIndex = 0;
      _logined = false;
    });
  }

  @override
  Widget build(BuildContext context) {

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


void main() {
  // 注册云信sdk
  NIMSDKBridge.doRegisterSDK();
  runApp(new CajianWidget());
}