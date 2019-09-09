/**
 *  Created by chenyn on 2019-07-23
 *  设置
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:cajian/Mine/Model/SettingModel.dart';
import 'package:cajian/Mine/View/SettingListCell.dart';
import 'package:flutter/services.dart';

class SettingWidget extends StatefulWidget {
  final String channelName;
  SettingWidget(this.channelName);

  SettingState createState() {
    return SettingState();
  }
}

class SettingState extends State<SettingWidget> {

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
            onPressed: () { _platform.invokeMethod('popFlutterViewController'); },
          ),
          title: Text(
            '设置',
            style: TextStyle(color: BlackColor),
          ),
          backgroundColor: MainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          color: MainBgColor,
          child: settingTable,
        ),
      ),
    );
  }
}
