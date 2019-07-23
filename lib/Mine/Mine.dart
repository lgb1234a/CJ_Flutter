/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'package:flutter/material.dart';
import 'Model/MineModel.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/View/MineListCell.dart';

class MineWidget extends StatefulWidget {

  MineState createState() {
    return new MineState();
  }
}

class MineState extends State<MineWidget> {

  @override
  Widget build(BuildContext context) {

    ListView mineTable = ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: mineCellModels.length,
      itemBuilder: (BuildContext context, int index) 
      {
        MineModel model = mineCellModels[index];
        if(model.type == MineCellType.Others) {
          return new MineListCellOthers(model);
        }else if(model.type == MineCellType.Separator) {
          return new MineListCellSeparator();
        }
        return new GestureDetector(
          child: new Padding(
              padding: new EdgeInsets.all(10.0),
              child: new Text("Row $index")),
          onTap: () {
            MineModel model = mineCellModels[index];
            model.onTap(context);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(indent: 16.0),
    );

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