/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'package:flutter/material.dart';

class MineWidget extends StatefulWidget {

  _mineState createState() {
    return new _mineState();
  }

}

class _mineState extends State<MineWidget> {

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(
      'Index 2: 我的',
      style: optionStyle,
    );
  }
}