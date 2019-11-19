/**
 * create by chenyn 2019-11-8
 * 联系人设置页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../../Base/CJUtils.dart';

class ContactSetting extends StatefulWidget {
  final Map params;
  ContactSetting(this.params);

  @override
  State<StatefulWidget> createState() {
    return ContactSettingState();
  }
}

class ContactSettingState extends State<ContactSetting> {
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
            '个人信息设置',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Center(
          child: Text('联系人设置页面'),
        ),
      ),
    );
  }
}
