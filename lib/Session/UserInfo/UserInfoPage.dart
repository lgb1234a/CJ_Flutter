
/**
 * created by chenyn 2019-11-7
 * 个人信息页
 */
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
    @override
  State<StatefulWidget> createState() {
    return UserInfoPageState();
  }
}


class UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text('个人信息页'),
        ),
      ),
    );
  }
}