
/**
 *  Created by chenyn on 2019-09-17
 *  flutter 全局消息总线（只能适用在同一个binaryMessenger下）
 */

import 'package:event_bus/event_bus.dart';

/// 发送事件：GlobalEventBus().event.fire(BackgroundColorChangeEvent(Colors.red)) ;
/// 监听：
/// GlobalEventBus().event.on<BackgroundColorChangeEvent>().listen((event) {
///      Color color = event.color;
/// 
/// });


class GlobalEventBus{
  EventBus event;
  factory GlobalEventBus() => _getInstance();

  static GlobalEventBus get instance => _getInstance();

  static GlobalEventBus _instance;

  GlobalEventBus._internal() {
    // 创建对象
    event = EventBus();
  }

  static GlobalEventBus _getInstance() {
    if (_instance == null) {
      _instance = GlobalEventBus._internal();
    }
    return _instance;
  }
}