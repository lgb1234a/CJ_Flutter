/**
 *  Created by chenyn on 2019-07-16
 *  云信SDK调用
 */

import 'package:flutter/services.dart';
import 'dart:async';

class NIMSDKBridge {
  static const _platform = const MethodChannel('com.zqtd.cajian/NIMSDK');

  // 注册云信sdk
  static Future<void> doRegisterSDK() async{
    await _platform.invokeMethod('registerSDK');
  }

  // sdk登录
  static Future<bool> doSDKLogin(
    String accid, 
    String token, 
    String name) async 
  {
    bool success = await _platform.invokeMethod('doLogin:', [accid, token, name]);
    return success;
  }
}