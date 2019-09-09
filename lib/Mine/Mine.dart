/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Model/MineModel.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/View/MineListCell.dart';

class MineWidget extends StatefulWidget {
  final String channelName;
  MineWidget(this.channelName);
  
  MineState createState() {
    return new MineState();
  }
}

class MineState extends State<MineWidget> {
  MethodChannel _platform;

  @override
  void initState() {
    super.initState();

    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
  }

  @override
  Widget build(BuildContext context) {

    ListView mineTable = ListView.separated(
      itemCount: mineCellModels.length,
      itemBuilder: (BuildContext context, int index) 
      {
        MineModel model = mineCellModels[index];
        model.platform = _platform;

        if(model.type == MineCellType.Others) {
          return new MineListCellOthers(model);
        }else if(model.type == MineCellType.Separator) {
          return new MineListCellSeparator();
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

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
            title: const Text(
                '我',
                style: TextStyle(color: Color(0xFF141414)),
            ),
            backgroundColor: WhiteColor,
            elevation: 0.01,
          ),
          body: Container(
            color: MainBgColor,
            child: mineTable,
          ),
        ),
    );
  }
}