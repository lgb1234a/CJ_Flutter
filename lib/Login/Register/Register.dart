/**
 *  Created by chenyn on 2019-11-19
 *  注册页
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Base/CJRequestEngine.dart';
import 'package:cajian/Login/Server.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'dart:async';

class RegisterWidget extends StatefulWidget {
  RegisterState createState() {
    return RegisterState();
  }
}

class RegisterState extends State<RegisterWidget> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _codeController = TextEditingController();
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
    _codeController.addListener(() {
      _textChange();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
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
        _codeController.text.trim().length > 0);
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
    return await NimSdkUtil.doSDKLogin(
        response['accid'], response['token'], name: response['name']);
  }

  // 登录
  Future<bool> _register() async {
    if (_phoneController.text.trim().length != 11) {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '请输入正确的手机号'});
      return false;
    }

    if (_codeController.text.trim().length != 6) {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '请输入正确的验证码'});
      return false;
    }

    loading(true);
    Result response =
        await register(_phoneController.text, _codeController.text);
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
                '注册',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: mainBgColor,
              elevation: 0.01,
              iconTheme: IconThemeData.fallback(),
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
                      child: TextFormField(
                        autofocus: true,
                        controller: _phoneController,
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                            hintText: "手机号（仅支持大陆手机）",
                            border: InputBorder.none),
                      ),
                    ),
                    Divider(
                      height: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: Colors.black12,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        SizedBox(
                            width: 200,
                            height: 40,
                            child: TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  border: InputBorder.none,
                                  hintText: '输入验证码'),
                            )),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                        ),
                        VerticalDivider(
                          width: 0.5,
                          color: Colors.black,
                        ),
                        FlatButton(
                          child: Text(
                            _countdownTime == 0
                                ? '获取验证码'
                                : '$_countdownTime' + 's后重新获取',
                            style:
                                TextStyle(fontSize: 16, color: blueColor),
                          ),
                          onPressed: _countdownTime == 0
                              ? () {
                                  if (_phoneController.text.trim().length !=
                                      11) {
                                    FlutterBoost.singleton.channel.sendEvent(
                                        'showTip', {'text': '请输入正确的手机号'});
                                    return;
                                  }

                                  if (_countdownTime == 0) {
                                    setState(() {
                                      _countdownTime = 60;
                                    });
                                    //开始倒计时
                                    startCountdownTimer();
                                  }
                                  if (_phoneController.text.trim().length > 0) {
                                    String phone = _phoneController.text.trim();
                                    sendAuthCode(phone).then((data) {
                                      if (data.success) {
                                        FlutterBoost.singleton.channel
                                            .sendEvent(
                                                'showTip', {'text': '验证码发送成功'});
                                      } else {
                                        FlutterBoost.singleton.channel
                                            .sendEvent('showTip', {
                                          'text': '发送失败:' + data.error.msg
                                        });
                                      }
                                    }).catchError(() {
                                      FlutterBoost.singleton.channel.sendEvent(
                                          'showTip', {'text': '网络开小差了～'});
                                    });
                                  }
                                }
                              : null,
                        ),
                      ],
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
                      child: FlatButton(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '注册',
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
                        textColor: Colors.white,
                        color: blueColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        highlightColor: Colors.blue[700],
                        disabledColor: Colors.blueGrey,
                        splashColor: Colors.grey,
                        onPressed: _confirmAvailabe && !_loading
                            ? () {
                                _register().then((success) {
                                  loading(false);
                                  if (success) {
                                    Navigator.pop(context);
                                  }
                                }).catchError(() {
                                  loading(false);
                                  FlutterBoost.singleton.channel.sendEvent(
                                      'showTip', {'text': '网络开小差了～'});
                                }).whenComplete(() => loading(false));
                              }
                            : null,
                      ),
                    ),
                  ],
                ))));
  }
}
