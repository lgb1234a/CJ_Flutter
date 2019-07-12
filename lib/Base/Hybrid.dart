/**
 *  Created by chenyn on 2019-07-12
 *  原生&flutter交互
 */

import 'package:flutter/services.dart';
import 'dart:async';

class Hybird {
  static const platform = const MethodChannel("com.zqtd.cajian/battery");

  static Future<Null> getBatteryLevel() async {
    String batteryLevel;
    try{
       print('dart-_getBatteryLevel');
       // 在通道上调用此方法
       await platform.invokeMethod('getBatteryLevel').then((value){
          print(value);
       }).catchError((error){
          print(error);
       });
    } on PlatformException catch (e){
       batteryLevel = "Failed to get battery level: '${e.message}'.";
       print(batteryLevel);
    }
  }
}