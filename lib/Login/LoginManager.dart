/**
 *  Created by chenyn on 2019-07-11
 *  登录状态管理类
 */
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

bindAccidAndToken(String accid, String token) {
  LoginManager().accid = accid;
  LoginManager().token = token;
}

class LoginManager {

  String _accid;
  String _token;

  String get accid {
    return _accid;
  }

  set accid(String a) {
    _accid = a;
    SharedPreferences.getInstance().then((sp){
      sp.setString('accid', a);
    });
  }

  String get token {
    return _token;
  }

  set token(String t) {
    _token = t;
    SharedPreferences.getInstance().then((sp){
      sp.setString('token', t);
    });
  }

  // 用本地accid和token登录云信
  Future<bool> login(String accid, String token) async {
    if(token == null || accid == null) {
      return false;
    }
    return NimSdkUtil.doSDKLogin(accid, token, '');
  }

  clearTokenAndAccid() {
    _accid = null;
    _token = null;
    SharedPreferences.getInstance().then((sp){
      sp.setString('token', null);
      sp.setString('accid', null);
    }).whenComplete((){
      NimSdkUtil.logout();
    });
  }

  // 登出
  logout() {
    clearTokenAndAccid();
  }

  // 单例公开访问点
  factory LoginManager() =>_sharedInstance();
  
  // 静态私有成员，没有初始化
  static LoginManager _instance = LoginManager._();
  
  // 私有构造函数
  LoginManager._() {
    // 具体初始化代码
    SharedPreferences.getInstance().then((sp){
      _accid = sp.getString('accid');
      _token = sp.getString('token');
    });
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
    // Map<String, String> arguments = {'scope':'snsapi_userinfo', 'state': 'get_access_token_bind'};
  }
}

