/**
 *  Created by chenyn on 2019-07-23
 *  设置
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/SettingModel.dart';
import 'package:cajian/Mine/View/SettingListCell.dart';
import 'package:flutter_boost/flutter_boost.dart';

class SettingWidget extends StatefulWidget {

  SettingState createState() {
    return SettingState();
  }
}

class SettingState extends State<SettingWidget> {

  @override
  void initState() {
    super.initState();
  }

  ListView settingTable = ListView.separated(
    itemCount: settingCellModels.length,
    itemBuilder: (BuildContext ctx, int index) {
      SettingModel model = settingCellModels[index];
      model.ctx = ctx;
      if (model.cellType == SettingCellType.Function) {
        return SettingFuncitonCell(model);
      } else if (model.cellType == SettingCellType.Separator) {
        return SettingSeparatorCell();
      } else if (model.cellType == SettingCellType.Accessory) {
        return SettingAccessoryCell(model);
      }

      return null;
    },
    separatorBuilder: (BuildContext context, int index) {
      SettingModel model = settingCellModels[index];
      if (model.needSeparatorLine) {
        return Container(
          color: Colors.white,
          child: Divider(indent: 16.0),
        );
      }
      return const Divider(height: 0);
    },
  );

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: Scaffold(
        appBar: new AppBar
        (
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () { 
              FlutterBoost.singleton.closeCurrent();
               },
          ),
          title: Text(
            '设置',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          color: mainBgColor,
          child: settingTable,
        ),
      ),
    );
  }
}
