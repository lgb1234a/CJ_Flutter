/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'package:flutter/material.dart';
import 'Model/MineModel.dart';
import 'package:cajian/Base/CJUtils.dart';

class MineWidget extends StatefulWidget {

  _mineState createState() {
    return new _mineState();
  }
}

class _mineState extends State<MineWidget> {

  @override
  Widget build(BuildContext context) {

    ListView mineTable = ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Text("Row $index")),
          onTap: () {
            MineModel model = entries[index];
            model.onTap();
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(indent: 16.0),
    );

    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: const Text(
            '我',
            style: TextStyle(color: Color(0xFF141414)),
        ),
        backgroundColor: WhiteColor,
        elevation: 0.01,
      ),
      body: mineTable,
    );
  }
}