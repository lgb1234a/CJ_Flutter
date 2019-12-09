/// Created by chenyn 2019-12-09
/// 群公告
///

import 'package:flutter/material.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';

class TeamAnnouncementPage extends StatefulWidget {
  final Map params;
  TeamAnnouncementPage({Key key, this.params}) : super(key: key);

  @override
  _TeamAnnouncementPageState createState() => _TeamAnnouncementPageState();
}

class _TeamAnnouncementPageState extends State<TeamAnnouncementPage> {
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
            '群公告',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          child: Center(
            child: Text('群公告'),
          ),
        ),
      ),
    );
  }
}
