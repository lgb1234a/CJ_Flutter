import 'dart:async';

import 'package:flutter/services.dart';

class Wechat {
  static const MethodChannel _channel =
      const MethodChannel('wechat');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
