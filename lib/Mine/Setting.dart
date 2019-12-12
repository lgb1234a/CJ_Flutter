///
///  Created by chenyn on 2019-07-23
///  设置

import 'package:cajian/Login/LoginManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:wx_sdk/wx_sdk.dart';

class SettingWidget extends StatefulWidget {
  SettingState createState() {
    return SettingState();
  }
}

class SettingState extends State<SettingWidget> {
  bool _loading = true;
  bool _bind = false;
  @override
  void initState() {
    super.initState();

    _load();
  }

  void _load() async {
    _bind = await WxSdk.wxBindStatus();

    setState(() {
      _loading = false;
    });
  }

  /// 安全
  Widget _security() {
    return Cell(
        Text('安全'),
        Icon(Icons.arrow_forward_ios),
        () =>
            FlutterBoost.singleton.open('security', exts: {'animated': true}));
  }

  ///
  Widget _wxBind() {
    return Cell(
        Text('绑定微信'),
        Row(children: [
          _loading ? CupertinoActivityIndicator() : Text(_bind ? '已绑定' : '未绑定'),
          Icon(Icons.arrow_forward_ios)
        ]), () {
      if (_loading || !_bind) {
        return;
      }
      cjDialog(context, '确定要解绑吗？', handlerTexts: [
        '确定'
      ], handlers: [
        () async {
          bool success = await WxSdk.unBindWeChat();
          if (success) {
            setState(() {
              _bind = false;
            });
          }
        }
      ]);
    });
  }

  ///
  Widget _blockedList() {
    return Cell(
        Text('黑名单'),
        Icon(Icons.arrow_forward_ios),
        () => FlutterBoost.singleton
            .open('block_list', exts: {'animated': true}));
  }

  ///
  Widget _logout() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: CupertinoButton.filled(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          '退出登录',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => cjDialog(context, '提示',
            content: Text('确定要退出登录吗？'),
            handlerTexts: ['确定'],
            handlers: [() => LoginManager().logout()]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '设置',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          children: <Widget>[
            _security(),
            Divider(
              indent: 12,
              height: 0.5,
            ),
            _wxBind(),
            Container(
              height: 8,
            ),
            _blockedList(),
            Container(
              height: 8,
            ),
            _logout()
          ],
        ),
      ),
    );
  }
}
