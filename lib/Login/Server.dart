/**
 *  Created by chenyn on 2019-07-15
 *  登录相关的网络请求
 */

import 'package:cajian/Base/CJRequestEngine.dart';

// 发送验证码
Future<Result> sendAuthCode(String phone) async {
  Result data = await CJRequestEngine.postJson('/g2/vecode/send', {'phone': phone});
  return data;
}

// 验证码登录
Future<Result> loginByCode(String phone, String code) async {
  Result response = await CJRequestEngine.postJson('/g2/login/vecode', {'phone': phone,'vecode': code});
  return response;
}

// 密码登录
Future<Result> loginByPwd(String phone, String pwd) async {
  Result response = await CJRequestEngine.postJson('/g2/login/passwd', {'passwd': pwd, 'phone': phone});
  return response;
}

