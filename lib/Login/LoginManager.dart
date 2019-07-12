/**
 *  Created by chenyn on 2019-07-11
 *  登录状态管理类
 */
import 'package:cajian/Base/CJUtils.dart';
import 'package:wechat/wechat.dart';
import 'package:cajian/Base/Hybrid.dart';

class LoginManager {
  // 单例公开访问点
  factory LoginManager() =>_sharedInstance();
  
  // 静态私有成员，没有初始化
  static LoginManager _instance = LoginManager._();
  
  // 私有构造函数
  LoginManager._() {
    // 具体初始化代码
  }

  // 静态、同步、私有访问点
  static LoginManager _sharedInstance() {
    return _instance;
  }

  // 注册微信
  registerWeChat(appid) {
  }

  // 获取登录token
  getAccessWeChatToken() {
    Map<String, String> arguments = {'scope':'snsapi_userinfo', 'state': 'get_access_token_bind'};
  }
}

