 ///
 ///  Created by chenyn on 2019-10-12
 ///  搜索抽象类
 ///
 import 'package:flutter/cupertino.dart';

typedef IndexedWidgetBuilder = CJSearchInterface Function(Map model);
abstract class CJSearchInterface {
  // 搜索关键词
  String keyword;

  @required 
  Map toJson();
}
