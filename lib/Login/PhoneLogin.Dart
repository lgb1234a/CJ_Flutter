/**
 *  Created by chenyn on 2019-07-12
 *  验证码登录
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Base/CJRequestEngine.dart';
import 'package:cajian/Login/Server.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/NIMSDKBridge.dart';
import 'dart:async';
import 'package:cajian/Base/NotificationCenter.dart';

class PhoneLoginWidget extends StatefulWidget {
  _phoneLoginState createState() {
    return new _phoneLoginState();
  }
}

class _phoneLoginState extends State<PhoneLoginWidget> {
  TextEditingController _phoneController = new TextEditingController();
  TextEditingController _codeController = new TextEditingController();
  GlobalKey _formKey= new GlobalKey<FormState>();
  bool _loading = false;
  String loginSuccessNotiName = 'loginSuccess';

  @override
  void dispose() {
    super.dispose();
    NotificationCenter.shared.removeObserver(loginSuccessNotiName);
  }

  loading(bool loading) {
    setState(() {
      _loading = loading;
    });
  }

  // 云信sdk登录
  Future<bool> sdkLogin(Map<String, dynamic> response) async {
    print('登录OK, response $response');
    return await NIMSDKBridge.doSDKLogin(
      response['accid'], 
      response['token'], 
      response['name']);
  }

  // 登录
  Future<bool> login() async {
    Result response = await loginByCode(_phoneController.text, _codeController.text);
    if(response.success) {
      return await sdkLogin(response.data);
    }else {
      print(response.error.msg);
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
                  // 校验用户名
                  validator: (v) {
                    return v
                        .trim()
                        .length > 0 ? null : "手机号不能为空";
                  }
                ),
              ),
              new Divider(
                height: 0.5,
                indent: 16,
                endIndent: 16,
                color: Colors.black12,
              ),
              new Row(
                children: <Widget>[
                  new SizedBox(
                    width: screenSize.width - 150,
                    height: 40,
                    child: new TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                        border: InputBorder.none,
                        hintText: '输入验证码'
                      ),
                      // 验证验证码
                      validator: (v) {
                        return v
                            .trim()
                            .length > 0 ? null : "请输入正确的验证码";
                      }
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
                    child: new Text('获取验证码', style: new TextStyle(fontSize: 16, color: BlueColor),),
                    onPressed: (){
                      if(_phoneController.text.trim().length > 0) {
                        String phone = _phoneController.text.trim();
                        sendAuthCode(phone);
                      }
                    },
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
              new FlatButton(
                  padding: EdgeInsets.symmetric(horizontal: (screenSize.width - 100)*0.5, vertical: 10),
                  child: new Text('登录', style: new TextStyle(fontSize: 16),),
                  textColor: Colors.white,
                  color: BlueColor,
                  shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                  highlightColor: Colors.blue[700],
                  splashColor: Colors.grey,
                  onPressed: (){
                    login().then((success){
                      if(success) {
                        Navigator.pop(context);
                        NotificationCenter.shared.postNotification(loginSuccessNotiName, context);
                      }
                    });
                  },
              ),
            ],
          )
      )
    );
  }
}