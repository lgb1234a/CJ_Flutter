/// Created by Chenyn 2019-12-10
/// 忘记密码
///
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_userInfo.dart';
import '../Base/CJUtils.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import '../Login/Server.dart';
import '../Base/CJRequestEngine.dart';

class PwdForgotPage extends StatefulWidget {
  final Map params;
  PwdForgotPage({Key key, this.params}) : super(key: key);

  @override
  _PwdForgotPageState createState() => _PwdForgotPageState(params['type'] ?? 0);
}

class _PwdForgotPageState extends State<PwdForgotPage> {
  _PwdForgotPageState(this.type);

  /// 0: 已登录状态  1: 未登录状态
  int type = 0;

  String _phone = '';
  TextEditingController _verifyInputController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  int _countdownTime = 0;
  Timer _timer;

  /// 需要手动输入手机号
  bool _needPhoneInput = false;

  @override
  void dispose() {
    _verifyInputController.dispose();
    _phoneController.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    print('type =============> $type');

    if (type == 0) {
      _fetchPhoneNumber();
    } else {
      setState(() {
        _needPhoneInput = true;
      });
    }
  }

  /// 倒计时
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

  /// 获取手机号
  _fetchPhoneNumber() async {
    UserInfo info = await NimSdkUtil.userInfoById();
    setState(() {
      _phone = info.mobile;
    });
  }

  ///
  Widget _inputTip() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Text('请输入$_phone收到的短信验证码'),
    );
  }

  /// 手机号输入
  Widget _phoneInput() {
    return Container(
      height: 44,
      color: Colors.white,
      child: CupertinoTextField(
        controller: _phoneController,
        decoration: BoxDecoration(border: null),
        placeholder: '手机号（仅支持大陆手机号）',
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }

  /// 验证码
  Widget _verifyInput() {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 200,
            child: CupertinoTextField(
              padding: EdgeInsets.symmetric(horizontal: 12),
              controller: _verifyInputController,
              decoration: BoxDecoration(border: null),
              placeholder: '输入验证码',
            ),
          ),
          Container(
            height: 44,
            child: Row(
              children: <Widget>[
                VerticalDivider(
                  width: 0.5,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                CupertinoButton(
                    padding: EdgeInsets.all(10),
                    onPressed: _countdownTime > 0 ? null : () => _sendCode(),
                    child: Text(
                      _countdownTime > 0 ? '$_countdownTime s后获取' : '获取验证码',
                      style: TextStyle(fontSize: 14),
                    ))
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 下一步
  _confirm() async {
    String vecode = _verifyInputController.text.trim();
    if (vecode.length != 6) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '请输入六位验证码'});
      return;
    }

    Result r = await forgotPwd(_phone, vecode);
    if (r == null) {
      return;
    }

    if (r.success) {
      FlutterBoost.singleton.open('pwd_setting',
          urlParams: {'accid': r.data['accid'], 'type': 1, 'phone': _phone},
          exts: {'animated': true});
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': r.error.msg});
    }
  }

  /// 发送验证码
  _sendCode() async {
    if (_countdownTime == 0) {
      setState(() {
        _countdownTime = 60;
      });
      //开始倒计时
      startCountdownTimer();
    }

    Result r = await sendAuthCode(_phone).catchError((error) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '网络开小差了～'});
    });

    if (r == null) {
      return;
    }

    if (r.success) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '验证码发送成功'});
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '发送失败:' + r.error.msg});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '找回登录密码',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          color: mainBgColor,
          child: ListView(
            children: <Widget>[
              _needPhoneInput ? _phoneInput() : _inputTip(),
              _needPhoneInput
                  ? Divider(
                      indent: 12,
                      height: 0.5,
                    )
                  : Container(),
              _verifyInput(),
              Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: CupertinoButton.filled(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    onPressed: () => _confirm(),
                    child: Text(
                      '下一步',
                      style: TextStyle(color: Colors.white),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
