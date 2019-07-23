/**
 *  Created by chenyn on 2019-07-12
 *  原生&flutter交互
 */

import 'package:flutter/services.dart';

class Hybird {
  static const _platform = const MethodChannel("com.zqtd.cajian/util");

  static showTip(String msg) {
    _platform.invokeMethod('showTip:', [msg]);
  }
}