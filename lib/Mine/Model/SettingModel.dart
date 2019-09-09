
/**
 *  Created by chenyn on 2019-07-23
 *  设置cell model
 */
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cajian/Login/LoginManager.dart';
import 'package:cajian/Base/CJUtils.dart';

enum SettingCellType {
  Function,    // 功能按钮
  Accessory,   // 入口
  Separator,   // 分割
} 

typedef TapCallback = void Function(SettingModel model);
class SettingModel {
  @required SettingCellType cellType;
  String title;
  String subTitle;
  Color  titleColor;
  TapCallback onTap;
  bool needSeparatorLine;
  BuildContext ctx;

  SettingModel(
    this.cellType, 
    this.title, 
    this.subTitle, 
    this.titleColor, 
    this.onTap, 
    {this.needSeparatorLine = true}
  );
}


final List<SettingModel> settingCellModels = [
  SettingModel(SettingCellType.Accessory, '安全', null, null, (SettingModel model){

  }),
  SettingModel(SettingCellType.Accessory, '绑定微信', '未绑定', null, (SettingModel model){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Accessory, '新消息通知', null, null, (SettingModel model){

  }),

  SettingModel(SettingCellType.Accessory, '黑名单', null, null, (SettingModel model){

  }),

  SettingModel(SettingCellType.Accessory, '清理缓存', null, null, (SettingModel model){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Accessory, '关于', null, null, (SettingModel model){

  }, needSeparatorLine: false),

  SettingModel(SettingCellType.Separator, null, null, null, null, needSeparatorLine: false),

  SettingModel(SettingCellType.Function, '退出登录', null, Color(0xFFFA5151), (SettingModel model){
    dialog(model.ctx, '提示', '确定要退出登录吗？', '确定', '取消', (){
      LoginManager().logout();
    }, (){
      
    });
    
  }),
];

