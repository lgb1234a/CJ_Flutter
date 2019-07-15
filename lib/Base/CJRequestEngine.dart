/**
 *  Created by chenyn on 2019-06-28
 *  网络请求
 */

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

// md5 加密
String generateMd5(String data) {
  // 这里其实就是 digest.toString()
  return md5.convert(utf8.encode(data)).toString();
}

class QueryStringPair {
  String key;
  var value;

  QueryStringPair(this.key, this.value);

  String URLEncodedStringValue() {
    if(value == null || value.length == 0) {
      return '';
    }else if(value is List){
      return '$key='+value.toString();
    }else if(value is Map) {
      QueryStringPair newPair = QueryStringPair(key, value);
      return newPair.URLEncodedStringValue();
    }
    else {
      return '$key=$value';
    }
  }
}

class CJRequestEngine {
  static final debug = true;
  static BuildContext context = null;
  static final host = 'https://api.youxi2018.cn';
  static final baseUrl = host;

  // ignore: argument_type_not_assignable
  static final Dio _dio = new Dio(new BaseOptions(
      method: "get",
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      followRedirects: true));

  /// 代理设置，方便抓包来进行接口调节
//  static void setProxy() {
//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//      // config the http client
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return "PROXY localhost:8888";
//      };
//      // you can also create a new HttpClient to dio
//      // return new HttpClient();
//    };
//  }

  static String accid;

  static final LogicError unknowError = LogicError(-1, "未知异常");

  static Future<Map<String, dynamic>> getJson<T>(
      String uri, Map<String, dynamic> paras) =>
      _httpJson("get", uri, data: paras).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> getForm<T>(
      String uri, Map<String, dynamic> paras) =>
      _httpJson("get", uri, data: paras, dataIsJson: false)
          .then(logicalErrorTransform);

  /// 表单方式的post
  static Future<Map<String, dynamic>> postForm<T>(
      String uri, Map<String, dynamic> paras) =>
      _httpJson("post", uri, data: paras, dataIsJson: false)
          .then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 post
  static Future<Map<String, dynamic>> postJson(
      String uri, Map<String, dynamic> body) =>
      _httpJson("post", uri, data: body).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> deleteJson<T>(
      String uri, Map<String, dynamic> body) =>
      _httpJson("delete", uri, data: body).then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 put
  static Future<Map<String, dynamic>> putJson<T>(
      String uri, Map<String, dynamic> body) =>
      _httpJson("put", uri, data: body).then(logicalErrorTransform);

  /// 表单方式的 put
  static Future<Map<String, dynamic>> putForm<T>(
      String uri, Map<String, dynamic> body) =>
      _httpJson("put", uri, data: body, dataIsJson: false)
          .then(logicalErrorTransform);

  /// 文件上传  返回json数据为字符串
  static Future<T> putFile<T>(String uri, String filePath) {
    var name =
    filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
    FormData formData = new FormData.from({
      "multipartFile": new UploadFileInfo(new File(filePath), name,
          contentType: ContentType.parse("image/$suffix"))
    });

    var enToken = accid == null ? "" : Uri.encodeFull(accid);
    return _dio
        .put<Map<String, dynamic>>("$uri?token=$enToken", data: formData)
        .then(logicalErrorTransform);
  }

  // 签名
  static String soltForUrlString(String url) {
    if(url == '/g1/share/app/get') {
      return 'e72557eeab0e2ae82eabaf91ecef8315';
    }else {
      return '74d6de00551d4db6a2a3e4484ba101ae';
    }
  }

  static String signForParams(String solt, Map<String, dynamic>params) {
    String query = 'solt='+solt+'&';
    var pairStrings = [];
    for (var key in params.keys) {
      QueryStringPair pair = QueryStringPair(key, params[key]);
      pairStrings.add(pair.URLEncodedStringValue());
    }

    return query + pairStrings.join('&');
  }

  static Future<Response<Map<String, dynamic>>> _httpJson(
      String method, String uri,
      {Map<String, dynamic> data, bool dataIsJson = true}) {
    var enToken = accid == null ? "" : Uri.encodeFull(accid);

    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
      data["accid"] = accid;
    }

    String sign = signForParams(soltForUrlString(uri), data);
    String signMd5 = generateMd5(sign);

    if (debug) {
      print('sign: ------ $sign  Md5: -------- $signMd5');
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    if (dataIsJson) {
      op = new Options(contentType: ContentType.parse("application/json"));
    } else {
      op = new Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"));
    }
    op.headers = {'sign': signMd5};
    op.method = method;
    // 开启网络请求日志
    _dio.interceptors.add(LogInterceptor(responseBody: false));

    return _dio.request<Map<String, dynamic>>(
        uri,
        data: data,
        queryParameters: data,
        options: op);
  }

  /// 对请求返回的数据进行统一的处理
  /// 如果成功则将我们需要的数据返回出去，否则进异常处理方法，返回异常信息
  static Future<T> logicalErrorTransform<T>(Response<Map<String, dynamic>> resp) {
    if (resp.data != null) {
      if (resp.data["code"] == 0) {
        T realData = resp.data["data"];
        return Future.value(realData);
      }
    }

    if (debug) {
      print('resp--------$resp');
      print('resp.data--------${resp.data}');
    }
    LogicError error;
    if (resp.data != null && resp.data["code"] != 0) {
      if (resp.data['data'] != null) {
        /// 失败时  错误提示在 data中时
        /// 收到token过期时  直接进入登录页面
        Map<String, dynamic> realData = resp.data["data"];
        error = new LogicError(resp.data["code"], realData['codeMessage']);
      } else {
        /// 失败时  错误提示在 message中时
        error = new LogicError(resp.data["code"], resp.data["message"]);
      }

      /// token失效 重新登录  后端定义的code码
      if (resp.data["code"] == 10000000) {
//        NavigatorUtils.goPwdLogin(context);

      }
      if(resp.data["code"] == 80000000){
        //操作逻辑
      }
    } else {
      error = unknowError;
    }
    return Future.error(error);
  }

  static getToken() {
    return accid;
  }
}

class LogicError {
  int errorCode;
  String msg;

  LogicError(errorCode, msg) {
    this.errorCode = errorCode;
    this.msg = msg;
  }
}

enum PostType { json, form, file }