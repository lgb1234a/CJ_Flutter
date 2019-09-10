/**
 *  Created by chenyn on 2019-07-12
 *  验证码登录
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Base/CJRequestEngine.dart';
import 'package:cajian/Login/Server.dart';
import 'package:flutter/cupertino.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'dart:async';
import 'LoginManager.dart';
import 'package:cajian/Base/Hybrid.dart';

class PhoneLoginWidget extends StatefulWidget {
  PhoneLoginState createState() {
    return new PhoneLoginState();
  }
}

class PhoneLoginState extends State<PhoneLoginWidget> {
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  GlobalKey _formKey= new GlobalKey<FormState>();
  bool _loading = false;
  Timer _timer;
  int _countdownTime = 0;
  bool _confirmAvailabe = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener((){
      _textChange();
    });
    _codeController.addListener((){
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
    if(valid != _confirmAvailabe) {
      setState((){
        _confirmAvailabe = valid;
      });
    }
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);

    var callback = (timer){
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
      response['accid'], 
      response['token'], 
      response['name']);
  }

  // 登录
  Future<bool> login(BuildContext context) async {
    if(_phoneController.text.trim().length != 11) {
      Hybird.showTip('请输入正确的手机号');
      return false;
    }

    if(_codeController.text.trim().length != 6) {
      Hybird.showTip('请输入正确的验证码');
      return false;
    }

    loading(true);
    Result response = await loginByCode(_phoneController.text, _codeController.text);
    if(response.success) {
      bindAccidAndToken(response.data['accid'], response.data['token']);
      return await sdkLogin(response.data);
    }else {
      Hybird.showTip(response.error.msg);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = getSize(context);
    
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('手机登录', style: new TextStyle(color: Colors.black),),
        backgroundColor: MainBgColor,
        elevation: 0.01,
        iconTheme: IconThemeData.fallback(),
      ),
      body: new Form(
        key: _formKey,
        autovalidate: true,
        child: new Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
            ),
              new SizedBox(
                height: 40,
                child: new TextFormField(
                  autofocus: true,
                  controller: _phoneController,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                      hintText: "手机号（仅支持大陆手机）",
                      border: InputBorder.none
                  ),
                ),
              ),
              new Divider(
                height: 0.5,
                indent: 16,
                endIndent: 16,
                color: Colors.black12,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new SizedBox(
                    width: 200,
                    height: 40,
                    child: new TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        border: InputBorder.none,
                        hintText: '输入验证码'
                      ),
                    )
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  new VerticalDivider(
                    width: 0.5,
                    color: Colors.black,
                  ),
                  new FlatButton(
                    child: new Text(
                      _countdownTime == 0 ?'获取验证码' : '$_countdownTime'+'s后重新获取', 
                      style: new TextStyle(fontSize: 16, color: BlueColor),
                    ),
                    onPressed: _countdownTime == 0 ?(){
                      if(_phoneController.text.trim().length != 11) {
                        Hybird.showTip('请输入正确的手机号');
                        return;
                      }

                      if (_countdownTime == 0) {
                        setState(() {
                          _countdownTime = 60;
                        });
                        //开始倒计时
                        startCountdownTimer();
                      }
                      if(_phoneController.text.trim().length > 0) {
                        String phone = _phoneController.text.trim();
                        sendAuthCode(phone).then((data){
                          if(data.success) {
                            Hybird.showTip('验证码发送成功');
                          }else {
                            Hybird.showTip('发送失败:'+data.error.msg);
                          }
                        }).catchError((){
                          Hybird.showTip('网络开小差了～');
                        });
                      }
                    } : null,
                  ),
                ],
              ),
              new Divider(
                height: 0.5,
                indent: 16,
                endIndent: 16,
                color: Colors.black12,
              ),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              new SizedBox(
                width: screenSize.width - 40,
                height: 40,
                child: new FlatButton(
                    child: new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text('登录', style: new TextStyle(fontSize: 16),),
                        new Padding(padding: EdgeInsets.symmetric(horizontal: _loading? 5:0),),
                        _loading? new CupertinoActivityIndicator(
                          animating: _loading,
                          radius: 10,
                        ): SizedBox()
                      ],
                    ),
                    textColor: Colors.white,
                    color: BlueColor,
                    shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    highlightColor: Colors.blue[700],
                    disabledColor: Colors.blueGrey,
                    splashColor: Colors.grey,
                    onPressed: _confirmAvailabe&&!_loading?(){
                      login(context).then((success){
                        loading(false);
                        if(success) {
                          Navigator.pop(context);
                        }
                      }).catchError((){
                        loading(false);
                        Hybird.showTip('网络开小差了～');
                      }).whenComplete(()=> loading(false));
                    }: null,
                ),
              ),
            ],
          )
      )
    );
  }
}