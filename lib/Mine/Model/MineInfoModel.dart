
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

enum MineInfoCellType {
  HeaderImg,    // 头像和图片
  Accessory,   // 入口
  Separator,   // 分割
} 

typedef TapCallback = void Function(MineInfoModel model);
class MineInfoModel {
  @required MineInfoCellType cellType;
  String title;
  String subTitle;
  Color  titleColor;
  TapCallback onTap;
  bool needSeparatorLine;
  BuildContext ctx;
  String iconTip;
  MineInfoModel(
    this.cellType, 
    this.title, 
    this.subTitle, 
    this.titleColor, 
    this.iconTip,
    this.onTap,
    {this.needSeparatorLine = true}
  );
}

Future<List> fetchModels() async {
    UserInfo info = await NimSdkUtil.userInfoById();
    final gender = info.gender;
    final genderStr = genderTransString(gender);
    final List models = [];
    models.add(MineInfoModel(MineInfoCellType.HeaderImg, '头像', null, null,
        info.avatarUrlString, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '手机号', info.mobile,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '昵称', info.showName,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '擦肩号', info.cajianNo,
        null, null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.HeaderImg, '我的二维码', null, null,
        'images/icon_settings_gray_qr@2x.png', (MineInfoModel model) {},
        needSeparatorLine: false));
    models.add(MineInfoModel(MineInfoCellType.Separator, null, null, null, null,
        (MineInfoModel model) {},
        needSeparatorLine: false));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '性别', genderStr, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '生日', info.birth, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '邮箱', info.email, null,
        null, (MineInfoModel model) {}));
    models.add(MineInfoModel(MineInfoCellType.Accessory, '签名', info.sign, null,
        null, (MineInfoModel model) {}));
    return models;
  }


String genderTransString(int type) {
  if (type == 0) {
    //未知性别
    return '未知';
  } else if (type == 1) {
    return '男';
  } else {
    return '女';
  }
}
