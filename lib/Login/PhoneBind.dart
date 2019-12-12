/// Created by Chenyn 2019-12-11
/// 绑定手机
///
import 'dart:async';
import 'package:cajian/Base/CJRequestEngine.dart';
import 'package:flutter/material.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:flutter/cupertino.dart';
import 'Server.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class PhoneBindPage extends StatefulWidget {
  final Map params;
  PhoneBindPage({Key key, this.params}) : super(key: key);

  @override
  _PhoneBindPageState createState() => _PhoneBindPageState();
}

class _PhoneBindPageState extends State<PhoneBindPage> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _verifyController = TextEditingController();
  int _countdownTime = 0;
  Timer _timer;
  bool _loading = false;
  bool _confirmAvailabe = false;

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _phoneController.dispose();
    _verifyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _verifyController.addListener(() {
      _confirmBtnIsEnabled(_verifyController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty);
    });
    _phoneController.addListener(() {
      _confirmBtnIsEnabled(_verifyController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty);
    });
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

  ///  绑定按钮是否可点击
  _confirmBtnIsEnabled(bool newValue) {
    if (newValue != _confirmAvailabe) {
      setState(() {
        _confirmAvailabe = !_loading && newValue;
      });
    }
  }

  /// 手机号
  Widget _phoneInput() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoTextField(
        placeholder: '输入手机号',
        decoration: BoxDecoration(border: null),
        controller: _phoneController,
      ),
    );
  }

  /// 发送验证码
  _sendCode() async {
    String phone = _phoneController.text.trim();

    if (phone.length != 11) {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '请输入正确的手机号'});
      return;
    }

    if (_countdownTime == 0) {
      setState(() {
        _countdownTime = 60;
      });
      //开始倒计时
      startCountdownTimer();
    }

    Result r = await sendAuthCode(phone).catchError((error) {
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

  /// 绑定手机号
  _bind() async {
    if (widget.params == null) {
      return;
    }
    setState(() {
      _loading = true;
    });
    String unionId = widget.params['union_id'];
    String headImg = widget.params['headimg'];
    String nickName = widget.params['nick_name'];
    String code = widget.params['code'];

    if (code == null) code = '';
    if (unionId == null) unionId = '';
    if (headImg == null) headImg = '';
    if (nickName == null) nickName = '';

    String phone = _phoneController.text.trim();
    String vecode = _verifyController.text.trim();

    Result r = await bindPhone(phone, vecode, code, unionId, nickName, headImg)
        .catchError((error) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '网络开小差了～'});
    }).whenComplete(() {
      setState(() {
        _loading = false;
      });
    });

    if (r == null) {
      return;
    }

    if (r.success) {
      NimSdkUtil.doSDKLogin(r.data['accid'], r.data['token']);
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': r.error.msg});
    }
  }

  /// 验证码
  Widget _verifyInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 200,
            child: CupertinoTextField(
              decoration: BoxDecoration(border: null),
              placeholder: '输入验证码',
              controller: _verifyController,
            ),
          ),
          VerticalDivider(
            indent: 10,
            endIndent: 10,
            thickness: 1,
            width: 0.5,
          ),
          CupertinoButton(
            onPressed: _countdownTime > 0 ? null : () => _sendCode(),
            child: _countdownTime > 0
                ? Text('$_countdownTime s后获取')
                : Text('获取验证码'),
          ),
        ],
      ),
    );
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
            '手机绑定',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          children: <Widget>[
            _phoneInput(),
            Divider(
              indent: 12,
              height: 0.5,
            ),
            _verifyInput(),
            Container(
              height: 20,
            ),
            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: CupertinoButton.filled(
                onPressed: _confirmAvailabe ? _bind : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('绑定'),
                    _loading
                        ? Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                ),
                                CupertinoActivityIndicator()
                              ],
                            ),
                          )
                        : Container()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
