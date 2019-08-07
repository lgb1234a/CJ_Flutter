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
    if(success) {
      _platform.invokeMethod('loginSuccess');
    }
    return success;
  }

  // 自动登录
  static void autoLogin(
    String accid, 
    String token, 
    String name){
    _platform.invokeMethod('autoLogin:', [accid, token, name]);
  }

  // 当前用户信息
  static Future<dynamic>currentUserInfo() async {
    dynamic info = await _platform.invokeMethod('currentUserInfo');
    return info;
  }

  // 获取群信息
  static Future<dynamic>teamInfoById(String teamId) async {
    dynamic teamInfo = await _platform.invokeMethod('teamInfo:', [teamId]);
    return teamInfo;
  }

  // 获取用户信息
  static Future<dynamic>userInfoById(String sessionId) async {
    dynamic userInfo = await _platform.invokeMethod('userInfo:', [sessionId]);
    return userInfo;
  }
}