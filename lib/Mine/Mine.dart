/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'package:flutter/material.dart';
import 'Model/MineModel.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/View/MineListCell.dart';

class MineWidget extends StatefulWidget {
  final Map params;
  MineWidget(this.params);

  MineState createState() {
    return MineState();
  }
}

class MineState extends State<MineWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bp = widget.params['bottom_padding'];
    
    Widget mineTable = ListView.separated(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bp),
      itemCount: mineCellModels.length,
      itemBuilder: (BuildContext context, int index) {
        MineModel model = mineCellModels[index];
        return cellForModel(model);
      },
      separatorBuilder: (BuildContext context, int index) {
        MineModel model = mineCellModels[index];
        if (model.needSeparatorLine) {
          return Divider(indent: 16.0, height: 0.5,);
        }
        return Container();
      },
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.01,
          brightness: Brightness.light,
        ),
        body: Container(
          color: mainBgColor,
          child: mineTable,
        ),
      ),
    );
  }
}
