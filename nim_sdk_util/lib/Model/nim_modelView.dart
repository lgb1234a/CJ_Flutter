/**
 * Created by chenyn on 2019-10-17
 * view model
 */
import 'package:flutter/material.dart';

abstract class NimSearchContactViewModel {
  
  @required
  Widget cell(Function onTap);
}