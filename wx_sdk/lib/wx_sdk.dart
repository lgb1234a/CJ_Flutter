import 'dart:async';

import 'package:flutter/services.dart';

class WxSdk {
  static const MethodChannel _channel =
      const MethodChannel('wx_sdk');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future wxLogin() async {
    await _channel.invokeMethod('wxlogin');
  }
}
