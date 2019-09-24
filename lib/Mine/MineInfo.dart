import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:flutter/services.dart';

import 'Model/MineInfoModel.dart';
import 'View/MineInfoListCell.dart';
class MineInfoWiget extends StatefulWidget{

  final String channelName;

  MineInfoWiget(this.channelName);

  _MineInfoState createState() => _MineInfoState();
}

class _MineInfoState extends State<MineInfoWiget>{

  MethodChannel _platform;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
  }
  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
  }

  ListView mineInfoTable = ListView.separated(
    itemCount: mineInfoCellModels.length,
    itemBuilder: (BuildContext ctx, int index) {
      MineInfoModel model = mineInfoCellModels[index];
      model.ctx = ctx;
      if (model.cellType == MineInfoCellType.Accessory) {
        return MineInfoAccessoryCell(model);
      } else if (model.cellType == MineInfoCellType.Separator) {
        return MineInfoSeparatorCell(model);
      }
      return null;
    },
    separatorBuilder: (BuildContext context, int index) {
      MineInfoModel model = mineInfoCellModels[index];
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
    // TODO: implement build
    return new MaterialApp(
      home: Scaffold(
        appBar: new AppBar
        (
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () { _platform.invokeMethod('popFlutterViewController'); },
          ),
          title: Text(
            '个人信息',
            style: TextStyle(color: BlackColor),
          ),
          backgroundColor: MainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          color: MainBgColor,
          child: mineInfoTable,
        ),
      ),
    );
  }

}