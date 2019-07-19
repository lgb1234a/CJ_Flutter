
import 'dart:async';

/**
 *  Created by chenyn on 2019-06-28
 *  工具类
 */

import 'package:flutter/material.dart';

Size getSize(BuildContext context) {
  final Size Screen_Size = MediaQuery.of(context).size;
  return Screen_Size;
}

final Color MainBgColor = Color(0xFFECECEC);
final Color WhiteColor  = Color(0xFFFCFCFC);
final Color BlackColor  = Color(0xFF141414);
final Color BlueColor   = Color(0xFF3092EE);

class CJUtils {

}

class CJNotification extends Notification {
  CJNotification(this.nName);
  final String nName;
}

// 弹窗
dialog(
    BuildContext context, 
    String title, 
    String msg, 
    String commitText,
    String cancelText,
    Function commitHandler, 
    Function cancelHandler) 
  {
    var commitWidget = commitHandler == null? SizedBox():new FlatButton(
                child: new Text(commitText!=null?commitText:'确定'),
                onPressed: () {
                  commitHandler();
                  Navigator.of(context).pop();
                },
              );
    
    var cancelWidget = cancelHandler == null? SizedBox():new FlatButton(
                child: new Text(cancelText!=null?cancelText:'取消'),
                onPressed: () {
                  cancelHandler();
                  Navigator.of(context).pop();
                },
              );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text((msg)),
            actions: <Widget>[
              cancelWidget,
              commitWidget
            ],
        )
    );
  }


// 临时弹窗
showTip(
    BuildContext context, 
    String title, 
    String msg, 
    int seconds)
  {
    const oneSec = const Duration(seconds: 1);

    Timer.periodic(oneSec, (timer){
      if(timer.tick == seconds) {
        Navigator.of(context).pop();
        timer.cancel();
      }
    });
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text((msg)),
        )
    );
  }