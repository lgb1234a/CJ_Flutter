/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cajian/Mine/Setting.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

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
  String tipIcon;
  bool   needSeparatorLine;
  
  MineModel(
    this.type, 
    this.title, 
    this.icon, 
    this.onTap, 
    {this.tipIcon, this.needSeparatorLine = false}
  );

  Future<dynamic> mineInfo() async {
    dynamic info = await NimSdkUtil.currentUserInfo();
    return info;
  }
}

final List<MineModel> mineCellModels = [
  MineModel(MineCellType.Profile, null, null, (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '扫一扫', 'images/icon_settings_scan@2x.png', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '我的钱包', 'images/icon_settings_alipay@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true),

  MineModel(MineCellType.Others, '云钱包', 'images/icon_setting_MFWallet@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true, tipIcon: 'images/icon_setting_MFWallet_recommend@2x.png'),

  MineModel(MineCellType.Others, '我的收款码', 'images/icon_settings_paycode@2x.png', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '收藏', 'images/icon_setting_collect@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true),

  MineModel(MineCellType.Others, '分享到微信', 'images/icon_setting_wx@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true),

  MineModel(MineCellType.Others, '帮助', 'images/icon_settings_about@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true),

  MineModel(MineCellType.Others, '联系客服', 'images/icon_setting_service@2x.png', (BuildContext ctx)=>{

  }, needSeparatorLine: true),

  MineModel(MineCellType.Others, '一键复制通讯录', 'images/icon_setting_copy_contacts@2x.png', (BuildContext ctx)=>{

  }),

  MineModel(MineCellType.Separator, null, null, null),

  MineModel(MineCellType.Others, '设置', 'images/icon_settings_general@2x.png', (BuildContext ctx){
    print('setting!');
    // 跳转设置页面
    Navigator.push(ctx, new MaterialPageRoute(builder: (BuildContext context){
      return SettingWidget();
    }));
  }),
];