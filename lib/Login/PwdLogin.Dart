/**
 *  Created by chenyn on 2019-07-12
 *  密码登录
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Base/CJRequestEngine.dart';
import 'package:cajian/Login/Server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'dart:async';

class PwdLoginWidget extends StatefulWidget {
  PwdLoginState createState() {
    return PwdLoginState();
  }
}

class PwdLoginState extends State<PwdLoginWidget> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _pwdController = TextEditingController();
  GlobalKey _formKey = GlobalKey<FormState>();
  bool _loading = false;
  Timer _timer;
  int _countdownTime = 0;
  bool _confirmAvailabe = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() {
      _textChange();
    });
    _pwdController.addListener(() {
      _textChange();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pwdController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  loading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  // 文本变化监听
  _textChange() {
    _confirmBtnStatus(_phoneController.text.trim().length > 0 &&
        _pwdController.text.trim().length > 0);
  }

  // 刷新登录按钮状态
  _confirmBtnStatus(bool valid) {
    if (valid != _confirmAvailabe) {
      setState(() {
        _confirmAvailabe = valid;
      });
    }
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer) {
      setState(() {
        if (_countdownTime < 1) {
          _timer.cancel();
        } else {
          _countdownTime = _countdownTime - 1;
        }
      });
    };

    _timer = Timer.periodic(oneSec, callback);
  }

  // 云信sdk登录
  Future<bool> sdkLogin(Map<String, dynamic> response) async {
    return await NimSdkUtil.doSDKLogin(response['accid'], response['token'],
        name: response['name']);
  }

  // 登录
  Future<bool> login() async {
    if (_phoneController.text.trim().length != 11) {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '请输入正确的手机号'});
      return false;
    }

    if (_pwdController.text.trim().length == 0) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '密码不能为空'});
      return false;
    }

    loading(true);
    Result response =
        await loginByPwd(_phoneController.text, _pwdController.text);
    if (response.success) {
      return await sdkLogin(response.data);
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': response.error.msg});
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: blackColor,
                  size: 22,
                ),
                onPressed: () => FlutterBoost.singleton.closeCurrent(),
              ),
              title: Text(
                '密码登录',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: mainBgColor,
              elevation: 0.01,
              iconTheme: IconThemeData.fallback(),
              actions: <Widget>[
                CupertinoButton(
                  child: Text('注册'),
                  onPressed: () => FlutterBoost.singleton
                      .open('register', exts: {'animated': true}),
                )
              ],
            ),
            body: Form(
                key: _formKey,
                autovalidate: true,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    SizedBox(
                      height: 40,
                      child: CupertinoTextField(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        placeholder: "手机号（仅支持大陆手机）",
                        autofocus: true,
                        controller: _phoneController,
                        decoration: BoxDecoration(border: null),
                      ),
                    ),
                    Divider(
                      height: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black12,
                    ),
                    SizedBox(
                      height: 40,
                      child: CupertinoTextField(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        placeholder: '输入登录密码',
                        controller: _pwdController,
                        obscureText: true,
                        decoration: BoxDecoration(
                          border: null,
                        ),
                      ),
                    ),
                    Divider(
                      height: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black12,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: 40,
                      child: CupertinoButton.filled(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '登录',
                              style: TextStyle(fontSize: 16),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: _loading ? 5 : 0),
                            ),
                            _loading
                                ? CupertinoActivityIndicator(
                                    animating: _loading,
                                    radius: 10,
                                  )
                                : SizedBox()
                          ],
                        ),
                        onPressed: _confirmAvailabe && !_loading
                            ? () {
                                login().then((success) {
                                  loading(false);
                                  if (success) {
                                    FlutterBoost.singleton.closeCurrent();
                                  }
                                }).catchError((e) {
                                  loading(false);
                                  FlutterBoost.singleton.channel.sendEvent(
                                      'showTip', {'text': '网络开小差了～'});
                                }).whenComplete(() => loading(false));
                              }
                            : null,
                      ),
                    ),
                    CupertinoButton(
                      child: Text('忘记密码'),
                      onPressed: () => FlutterBoost.singleton.open('pwd_forgot',
                          urlParams: {'type': 1}, exts: {'animated': true}),
                    )
                  ],
                ))));
  }
}
