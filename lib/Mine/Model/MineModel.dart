/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cajian/Mine/Setting.dart';

enum MineCellType {
  Profile,    // 用户信息
  Separator,  // 分割
  Others,     // 其他
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
  MineModel(MineCellType.Profile, null, null, (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '扫一扫', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '我的钱包', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Others, '支付宝钱包', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '收藏', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Others, '分享到微信', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Others, '帮助', '', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '设置', '', (BuildContext ctx){
    print('setting!');
    // 跳转设置页面
    Navigator.push(ctx, new MaterialPageRoute(builder: (BuildContext context){
      return SettingWidget();
    }));
  }),
];