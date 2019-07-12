import 'dart:convert';

/**
 *  Created by chenyn on 2019-07-12
 *  验证码登录
 */

import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';

class PhoneLoginWidget extends StatefulWidget {
  _phoneLoginState createState() {
    return new _phoneLoginState();
  }
}

class _phoneLoginState extends State<PhoneLoginWidget> {

  @override
  Widget build(BuildContext context) {
    Size screenSize = getSize(context);
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('手机登录', style: new TextStyle(color: Colors.black),),
        backgroundColor: MainBgColor,
        elevation: 0.01,
        iconTheme: IconThemeData.fallback(),
      ),
      body: new Column(
        children: <Widget>[
            new TextField(
              decoration: InputDecoration(
                hintText: '手机号（仅支持大陆手机）',
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
                  width: screenSize.width,
                  child: new TextField(
                  decoration: InputDecoration(
                    hintText: '验证码',
                  ),
                 ),
                ),

                
              ],
             ),
            
            new Divider(
              height: 0.5,
              indent: 16,
              endIndent: 16,
              color: Colors.black12,
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

              },
            ),
          ],
      )
    );
  }
}