/**
 *  Created by chenyn on 2019-07-18
 *  通知中心
 */
import 'package:flutter/material.dart';
import 'package:cajian/Base/Hybrid.dart';

class NotificationPair {
  String notificationName;
  Function notificationHandler;
  
  NotificationPair(this.notificationName, this.notificationHandler);


  post(dynamic context) {
    notificationHandler(context);
  }
}

class NotificationCenter {
  // 工厂模式
  factory NotificationCenter() => _getInstance();

  static NotificationCenter get shared => _getInstance();
  static NotificationCenter _instance;

  NotificationCenter._internal() {
    // 初始化
  }

  static NotificationCenter _getInstance() {
    if (_instance == null) {
      _instance = new NotificationCenter._internal();
    }
    return _instance;
  }

  //创建Map来记录名称
  Map<String, NotificationPair> postNameMap = Map<String, NotificationPair>();


  Map<String, Function> functionMap = Map<String, Function>();

  //添加监听者方法
  addObserver(String postName, object(dynamic object)) {
    // 初始化一个notificationPair
    NotificationPair pair = NotificationPair(postName, object);
    postNameMap[postName] = pair;
  }

  //发送通知传值
  postNotification(String postName, dynamic object) {
    //检索Map是否含有postName
    if (postNameMap.containsKey(postName)) 
    {
      debugPrint('did post notification: $postName');
      postNameMap[postName].post(object);
    }
    // 通知native
    Hybird.postNotification(postName, object);
  }

  // 移除监听
  removeObserver(String postName) {
    debugPrint('remove notification: $postName');
    postNameMap.remove(postName);
  }
}