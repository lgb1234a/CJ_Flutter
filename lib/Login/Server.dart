
/**
 *  Created by chenyn on 2019-06-28
 *  登录相关的网络请求
 */


import 'package:cajian/Base/CJRequestEngine.dart';

// 发送验证码
Future<Map<String,dynamic>> sendAuthCode(phone) async {
  Map<String,dynamic> data = await CJRequestEngine.postJson('/g2/vecode/send', {'phone': phone});
  return data;
}

