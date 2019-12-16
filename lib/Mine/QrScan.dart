/// Created by Chenyn 2019-12-12
/// 扫一扫

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class QrScanPage extends StatelessWidget {

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
            '扫一扫',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Center(
            child: SizedBox(
                width: 300.0,
                height: 600.0,
                child: Container())),
      ),
    );
  }
}
