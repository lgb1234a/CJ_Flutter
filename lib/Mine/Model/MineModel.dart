/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cajian/Mine/Setting.dart';
import 'package:flutter/widgets.dart';

enum MineCellType {
  MineCellTypeProfile,
  MineCellTypeSeparator,
  MineCellTypeOthers,
}
typedef TapCallback = void Function(BuildContext ctx);
class MineModel {
  @required MineCellType type;
  TapCallback onTap;
  String title;
  String icon;
  
  MineModel(this.type, this.title, this.icon, this.onTap);
}

final List<MineModel> mineCellModels = [
  MineModel(MineCellType.MineCellTypeProfile, null, null, (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel(MineCellType.MineCellTypeOthers, '扫一扫', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel(MineCellType.MineCellTypeOthers, '我的钱包', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeOthers, '支付宝钱包', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel(MineCellType.MineCellTypeOthers, '收藏', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeOthers, '分享到微信', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeOthers, '帮助', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.MineCellTypeSeparator, null, null, null),

  MineModel(MineCellType.MineCellTypeOthers, '设置', '', (BuildContext ctx){
    print('setting!');
    // 跳转设置页面
    Navigator.push(ctx, new MaterialPageRoute(builder: (BuildContext context){
      return SettingWidget();
    }));
  }),
];