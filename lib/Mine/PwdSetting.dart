/// Created by Chenyn 2019-12-10
/// 设置密码

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';
import '../Base/CJRequestEngine.dart';
import '../Login/LoginManager.dart';
import 'package:flutter/cupertino.dart';

class PwdSettingPage extends StatefulWidget {
  PwdSettingPage({Key key}) : super(key: key);

  @override
  _PwdSettingPageState createState() => _PwdSettingPageState();
}

class _PwdSettingPageState extends State<PwdSettingPage> {
  bool _pwdSetted = false;
  bool _confirmAvailabe = false;
  bool _loading = false;
  TextEditingController _originController = TextEditingController();
  TextEditingController _newController = TextEditingController();
  TextEditingController _repeatController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadPwdStatus();

    _originController.addListener(() {
      _confirmBtnEnable(_verify());
    });

    _newController.addListener(() {
      _confirmBtnEnable(_verify());
    });

    _repeatController.addListener(() {
      _confirmBtnEnable(_verify());
    });
  }

  bool _verify() {
    if (_pwdSetted) {
      return _originController.text.trim().isNotEmpty &&
          _newController.text.trim().isNotEmpty &&
          _repeatController.text.trim().isNotEmpty;
    }
    return _newController.text.trim().isNotEmpty &&
        _repeatController.text.trim().isNotEmpty;
  }

  _confirmBtnEnable(bool newValue) {
    if (newValue != _confirmAvailabe) {
      setState(() {
        _confirmAvailabe = !_loading && newValue;
      });
    }
  }

  /// 是否设置过密码
  _loadPwdStatus() async {
    String accid = await LoginManager().getAccid();
    Result r =
        await CJRequestEngine.postJson('/g2/passwd/exist', {'accid': accid})
            .catchError((e) => FlutterBoost.singleton.channel
                .sendEvent('showTip', {'text': '网络开小差了～'}));

    if (r == null) {
      return;
    }

    if (r.success) {
      setState(() {
        _pwdSetted = r.data;
      });
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': r.error.msg});
    }
  }

  /// 设置新密码
  _setPwd() {
    String originInputPwd = _originController.text.trim();
    String newInputPwd = _newController.text.trim();
    String repeatInputPwd = _repeatController.text.trim();

    if (newInputPwd != repeatInputPwd) {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': '两次密码输入不一致'});
      return;
    }

    setState(() {
      _loading = true;
    });
    if (_pwdSetted) {
      /// 刷新密码
      _updatePwd(originInputPwd, newInputPwd);
    } else {
      /// 创建密码
      _createPwd(newInputPwd);
    }
  }

  /// 创建密码请求
  _createPwd(String pwd) async {
    String accid = await LoginManager().getAccid();
    Result r = await CJRequestEngine.postJson(
            '/g2/passwd/set', {'accid': accid, 'passwd': pwd})
        .catchError((e) => FlutterBoost.singleton.channel
            .sendEvent('showTip', {'text': '网络开小差了～'}))
        .whenComplete(() {
      setState(() {
        _loading = false;
      });
    });

    if (r == null) {
      return;
    }

    if (r.success) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '密码设置成功'});
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': r.error.msg});
    }
  }

  /// 更新密码
  _updatePwd(String originPwd, String newPwd) async {
    String accid = await LoginManager().getAccid();
    Result r = await CJRequestEngine.postJson('/g2/passwd/update',
            {'accid': accid, 'new_passwd': newPwd, 'old_passwd': originPwd})
        .catchError((e) => FlutterBoost.singleton.channel
            .sendEvent('showTip', {'text': '网络开小差了～'}))
        .whenComplete(() {
      setState(() {
        _loading = false;
      });
    });

    if (r == null) {
      return;
    }

    if (r.success) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '密码修改成功'});
    } else {
      FlutterBoost.singleton.channel
          .sendEvent('showTip', {'text': r.error.msg});
    }
  }

  /// 原密码
  Widget _originPwdInput() {
    return _pwdSetted
        ? Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: CupertinoTextField(
              obscureText: true,
              placeholder: '原密码',
              decoration: BoxDecoration(border: null),
              controller: _originController,
            ),
          )
        : Container();
  }
  /// 新密码
  Widget _newPwdInput() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoTextField(
        obscureText: true,
        placeholder: '新密码',
        decoration: BoxDecoration(border: null),
        controller: _newController,
      ),
    );
  }

  /// 再次输入新密码
  Widget _repeatPwdInput() {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: CupertinoTextField(
        obscureText: true,
        placeholder: '再次输入新密码',
        decoration: BoxDecoration(border: null),
        controller: _repeatController,
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
            '设置登录密码',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          children: <Widget>[
            _originPwdInput(),
            _pwdSetted
                ? Divider(
                    indent: 12,
                    height: 0.5,
                  )
                : Container(),
            _newPwdInput(),
            Divider(
              indent: 12,
              height: 0.5,
            ),
            _repeatPwdInput(),
            Container(
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                margin: EdgeInsets.only(top: 15),
                child: CupertinoButton.filled(
                  onPressed: _confirmAvailabe ? _setPwd : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('确定'),
                      _loading
                          ? Container(
                              padding: EdgeInsets.all(5),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                  ),
                                  CupertinoActivityIndicator()
                                ],
                              ),
                            )
                          : Container()
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
