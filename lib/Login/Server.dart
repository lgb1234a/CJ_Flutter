/**
 *  Created by chenyn on 2019-07-15
 *  登录相关的网络请求
 */

import 'package:cajian/Base/CJRequestEngine.dart';

// 发送验证码
Future<Result> sendAuthCode(String phone) async {
  Result data =
      await CJRequestEngine.postJson('/g2/vecode/send', {'phone': phone});
  return data;
}

// 验证码登录
Future<Result> loginByCode(String phone, String code) async {
  Result response = await CJRequestEngine.postJson(
      '/g2/login/vecode', {'phone': phone, 'vecode': code});
  return response;
}

// 密码登录
Future<Result> loginByPwd(String phone, String pwd) async {
  Result response = await CJRequestEngine.postJson(
      '/g2/login/passwd', {'passwd': pwd, 'phone': phone});
  return response;
}

// 注册
Future<Result> register(String phone, String code) async {
  Result response = await CJRequestEngine.postJson(
      '/g2/user/register', {'phone': phone, 'vecode': code});
  return response;
}

/// wx登录绑定手机号
Future<Result> bindPhone(String phone, String vecode, String code,
    String unionId, String nickName, String headImg) async {
  Result response = await CJRequestEngine.postJson('/g2/login/wx/new', {
    'code': code,
    'head_img': headImg,
    'nick_name': nickName,
    'phone': phone,
    'union_id': unionId,
    'vecode': vecode,
  });
  return response;
}
