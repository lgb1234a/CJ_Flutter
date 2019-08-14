/**
 *  Created by chenyn on 2019-07-12
 *  原生&flutter交互
 */

import 'package:flutter/services.dart';

class Hybird {
  static final _platform = new MethodChannel("com.zqtd.cajian/util")
                                ..setMethodCallHandler(handler);

  static showTip(String msg) {
    _platform.invokeMethod('showTip:', [msg]);
  }

  static postNotification(String notificationName, dynamic notification) {
    _platform.invokeMethod('postNotification:', [notificationName, notification]);
  }

  static Future<dynamic> handler(MethodCall call) async {
    if(call.method == '') {
      
    }
  }
}