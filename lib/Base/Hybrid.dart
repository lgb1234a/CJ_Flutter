/**
 *  Created by chenyn on 2019-07-12
 *  原生&flutter交互
 */

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Hybird {
  static const platform = const MethodChannel("com.zqtd.cajian/battery");

  static Future<Null> getBatteryLevel() async {
    String batteryLevel;
    try{
       debugPrint('dart-_getBatteryLevel');
       // 在通道上调用此方法
       await platform.invokeMethod('getBatteryLevel').then((value){
          debugPrint(value);
       }).catchError((error){
          debugPrint(error);
       });
    } on PlatformException catch (e){
       batteryLevel = "Failed to get battery level: '${e.message}'.";
       debugPrint(batteryLevel);
    }
  }
}