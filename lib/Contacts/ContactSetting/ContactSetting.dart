/**
 * create by chenyn 2019-11-8
 * 联系人设置页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ContactSetting extends StatefulWidget {
  final Map params;
  final String channelName;
  ContactSetting(this.params, this.channelName);

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
        body: Center(
          child: Text('联系人设置页面'),
        ),
      ),
    );
  }
}
