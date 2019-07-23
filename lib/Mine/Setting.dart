/**
 *  Created by chenyn on 2019-07-23
 *  设置
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingWidget extends StatefulWidget {
  SettingState createState() {
    return SettingState();
  }
}

class SettingState extends State<SettingWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        title: Text('设置'),
      ),
      body: Text(
      '设置'
      ),
    );
  }
}