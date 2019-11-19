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

    ListView mineTable = ListView.separated(
      itemCount: mineCellModels.length,
      itemBuilder: (BuildContext context, int index) 
      {
        MineModel model = mineCellModels[index];
        
        if(model.type == MineCellType.Others) {
          return MineListCellOthers(model);
        }else if(model.type == MineCellType.Separator) {
          return MineListCellSeparator();
        }else if(model.type == MineCellType.Profile) {
          return MineListProfileHeader(model);
        }
        return null;
      },
      separatorBuilder: (BuildContext context, int index) {
        MineModel model = mineCellModels[index];
        if(model.needSeparatorLine) {
          return Container(
            color: Colors.white,
            child: Divider(indent: 16.0),
          );
        }
        return const Divider(height: 0);
      },
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text(
                '我',
                style: TextStyle(color: Color(0xFF141414)),
            ),
            backgroundColor: whiteColor,
            elevation: 0.01,
          ),
          body: Container(
            color: mainBgColor,
            child: mineTable,
          ),
        ),
    );
  }
}