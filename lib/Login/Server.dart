
/**
 *  Created by chenyn on 2019-07-15
 *  登录相关的网络请求
 */


import 'package:cajian/Base/CJRequestEngine.dart';

// 发送验证码
Future<Map<String,dynamic>> sendAuthCode(String phone) async {
  Map<String,dynamic> data = await CJRequestEngine.postJson('/g2/vecode/send', {'phone': phone});
  return data;
}

// 验证码登录
Future<Map<String, dynamic>> loginByCode(String phone, String code) async {
  Map<String,dynamic> data = await CJRequestEngine.postJson('/g2/login/vecode', {'phone': phone,'vecode': code});
  return data;
}

