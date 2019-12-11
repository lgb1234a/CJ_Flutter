/// Created by Chenyn 2019-12-11
/// 黑名单

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class BlockListPage extends StatefulWidget {
  BlockListPage({Key key}) : super(key: key);

  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {

  @override
  void initState() { 
    super.initState();
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
            '黑名单',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(),
      ),
    );
  }
}