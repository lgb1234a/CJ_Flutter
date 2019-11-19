import 'package:cajian/Mine/Dao/MineInfoDao.dart';
import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'Model/MineInfoModel.dart';
import 'View/MineInfoListCell.dart';

class MineInfoWiget extends StatefulWidget {

  _MineInfoState createState() => _MineInfoState();
}

class _MineInfoState extends State<MineInfoWiget> {
  List _cellModels = [];
  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    List models = await MineInfoDao.fetchModels();
    setState(() {
      _cellModels = models;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '个人信息',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Container(
          color: mainBgColor,
          child: ListView.separated(
            itemCount: _cellModels.length,
            itemBuilder: (BuildContext ctx, int index) {
              MineInfoModel model = _cellModels[index];
              model.ctx = ctx;
              if (model.cellType == MineInfoCellType.HeaderImg) {
                var image;
                if (model.iconTip != null && model.iconTip.contains('http')) {
                  image = model.iconTip != null
                      ? FadeInImage.assetNetwork(
                          image: model.iconTip,
                          width: 44,
                          placeholder: 'images/icon_avatar_placeholder@2x.png',
                        )
                      : Image.asset(
                          'images/icon_avatar_placeholder@2x.png',
                          width: 44,
                        );
                } else {
                  image = Image.asset(
                    model.iconTip == null ? '' : model.iconTip,
                  );
                }
                return HeaderImgCell(model, image);
              } else if (model.cellType == MineInfoCellType.Accessory) {
                return MineInfoAccessoryCell(model);
              } else if (model.cellType == MineInfoCellType.Separator) {
                return MineInfoSeparatorCell(model);
              }
              return null;
            },
            separatorBuilder: (BuildContext context, int index) {
              MineInfoModel model = _cellModels[index];
              if (model.needSeparatorLine) {
                return Container(
                  color: Colors.white,
                  child: Divider(indent: 16.0),
                );
              }
              return const Divider(height: 0);
            },
          ),
        ),
      ),
    );
  }
}
