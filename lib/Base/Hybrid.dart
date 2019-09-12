/**
 *  Created by chenyn on 2019-07-12
 *  原生&flutter交互
 */

import 'package:flutter/services.dart';
import 'package:cajian/Login/LoginManager.dart';

class Hybird {
  static final _platform = new MethodChannel("com.zqtd.cajian/util")
                                ..setMethodCallHandler(handler);

  static showTip(String msg) {
    _platform.invokeMethod('showTip:', [msg]);
  }

  static Future<dynamic> handler(MethodCall call) async {
    if(call.method == 'logout') {
      LoginManager().logout();
    }
  }
}