/**
 *  Created by chenyn on 2019-06-28
 *  工具类
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

Size getSize(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  return screenSize;
}

double topPadding(BuildContext context) {
  final double topPadding = MediaQuery.of(context).padding.top;
  return topPadding;
}

double bottomPadding(BuildContext context) {
  final double bottomPadding = MediaQuery.of(context).padding.bottom;
  return bottomPadding;
}

final Color MainBgColor = Color(0xFFECECEC);
final Color WhiteColor = Color(0xFFFCFCFC);
final Color BlackColor = Color(0xFF141414);
final Color BlueColor = Color(0xFF3092EE);

class CJUtils {}

// 弹窗
dialog(BuildContext context, String title, String msg, String commitText,
    String cancelText, Function commitHandler, Function cancelHandler) {
  var commitWidget = commitHandler == null
      ? SizedBox()
      : new FlatButton(
          child: new Text(
            commitText != null ? commitText : '确定',
            style: TextStyle(color: Colors.blue),
          ),
          onPressed: () {
            commitHandler();
            Navigator.of(context).pop();
          },
        );

  var cancelWidget = cancelHandler == null
      ? SizedBox()
      : new FlatButton(
          child: new Text(
            cancelText != null ? cancelText : '取消',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            cancelHandler();
            Navigator.of(context).pop();
          },
        );

  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text((msg)),
            actions: <Widget>[cancelWidget, commitWidget],
          ));
}
