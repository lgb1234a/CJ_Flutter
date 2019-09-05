import 'dart:async';

import 'package:flutter/services.dart';

class NimSdkUtil {
  static const MethodChannel _channel =
      const MethodChannel('nim_sdk_util');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 注册云信sdk
  static Future<void> doRegisterSDK() async{
    await _channel.invokeMethod('registerSDK');
  }

  /// sdk登录
  static Future<bool> doSDKLogin(
    String accid, 
    String token, 
    String name) async 
  {
    bool success = await _channel.invokeMethod('doLogin:', [accid, token, name]);
    return success;
  }

  /// 自动登录
  static void autoLogin(
    String accid, 
    String token, 
    String name){
    _channel.invokeMethod('autoLogin:', [accid, token, name]);
  }

  /// 登出
  static void logout() {
    _channel.invokeMethod('logout');
  }

  // 当前用户信息
  static Future<dynamic>currentUserInfo() async {
    dynamic info = await _channel.invokeMethod('currentUserInfo:');
    return info;
  }

  // 获取群信息
  static Future<dynamic>teamInfoById(String teamId) async {
    dynamic teamInfo = await _channel.invokeMethod('teamInfo:', [teamId]);
    return teamInfo;
  }

  // 获取用户信息
  static Future<dynamic>userInfoById(String sessionId) async {
    dynamic userInfo = await _channel.invokeMethod('userInfo:', [sessionId]);
    return userInfo;
  }

  // 获取好友列表
  static Future<List>friends() async {
    List friends = await _channel.invokeMethod('friends:');
    return friends;
  }
}
