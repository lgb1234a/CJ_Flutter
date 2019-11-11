/**
 * Created by chenyn on 2019-10-17
 * view model
 */
import 'package:flutter/material.dart';

abstract class NimSearchContactViewModel {

  // 搜索关键词
  String keyword;

  @required 
  Map toJson();
  
  @required
  Widget cell(Function onTap);
}