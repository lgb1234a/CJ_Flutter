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

final Color mainBgColor = Color(0xFFECECEC);
final Color whiteColor = Color(0xFFFCFCFC);
final Color blackColor = Color(0xFF141414);
final Color blueColor = Color(0xFF3092EE);
final Color appBarColor = Color(0xffe5e5e5);

class CJUtils {}

// 弹窗 handlerTexts <-> handlers  一一对应，不然会报错
cjDialog(BuildContext context, String title,
    {String msg,
    String cancelText = '取消',
    Function cancelHandler,
    List<String> handlerTexts,
    List<Function> handlers}) {
  assert(handlers.length == handlerTexts.length);

  showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: handlerTexts.map((f) {
              int idx = handlerTexts.indexOf(f);
              Function handler = handlers[idx];

              return CupertinoDialogAction(
                onPressed: () {
                  handler();
                  Navigator.of(context).pop();
                },
                child: Text(
                  f,
                  style: TextStyle(color: Colors.blue),
                ),
              );
            }).toList()
              ..add(CupertinoDialogAction(
                onPressed: () {
                  cancelHandler != null && cancelHandler();
                  Navigator.of(context).pop();
                },
                isDefaultAction: true,
                child: Text(cancelText),
                textStyle: TextStyle(color: Colors.red),
              )),
          ));
}

// 底部弹窗组件 handlerTexts <-> handlers  一一对应，不然会报错
cjSheet(BuildContext context, String title,
    {String msg,
    String cancelText = '取消',
    Function cancelHandler,
    List<String> handlerTexts,
    List<Function> handlers}) {
  assert(handlers.length == handlerTexts.length);

  showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
            title: Text(title),
            message: Text(msg),
            actions: handlerTexts.map((f) {
              int idx = handlerTexts.indexOf(f);
              Function handler = handlers[idx];

              return CupertinoActionSheetAction(
                onPressed: () {
                  handler();
                  Navigator.of(context).pop();
                },
                child: Text(
                  f,
                  style: TextStyle(color: Colors.red),
                ),
              );
            }).toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                cancelHandler != null && cancelHandler();
                Navigator.of(context).pop();
              },
              isDefaultAction: true,
              child: Text(cancelText),
            ),
          ));
}

class CJAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final Widget leading;
  final List<Widget> actions;
  final Widget flexibleSpace;
  final PreferredSizeWidget bottom;

  CJAppBar(
    this.title, {
    this.titleColor = const Color(0xFF141414),
    this.leading,
    this.backgroundColor = const Color(0xFFFCFCFC),
    this.actions,
    this.flexibleSpace,
    this.bottom,
  }) : preferredSize = Size.fromHeight(
            kToolbarHeight + bottom?.preferredSize?.height ?? 0.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: titleColor),
      ),
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      backgroundColor: backgroundColor,
      elevation: 0.01,
    );
  }

  @override
  final Size preferredSize;
}
