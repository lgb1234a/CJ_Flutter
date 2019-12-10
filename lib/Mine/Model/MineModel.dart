/**
 *  Created by chenyn on 2019-07-08
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_userInfo.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:wx_sdk/wx_sdk.dart';

enum MineCellType {
  Profile, // 用户信息
  Separator, // 分割
  Others, // 其他
}
typedef TapCallback = void Function(MineModel model);

class MineModel {
  @required
  MineCellType type;
  TapCallback onTap;
  String title;
  String icon;
  String tipIcon;
  bool needSeparatorLine;
  MethodChannel platform;

  MineModel(this.type, this.title, this.icon, this.onTap,
      {this.tipIcon, this.needSeparatorLine = false});

  Future<UserInfo> mineInfo() async {
    UserInfo info = await NimSdkUtil.userInfoById();
    return info;
  }
}

final List<MineModel> mineCellModels = [
  MineModel(MineCellType.Profile, null, null, (MineModel model) {
    FlutterBoost.singleton
        .open('mine_info', exts: {'animated': true}).then((Map value) {});
  }),
  MineModel(MineCellType.Separator, null, null, null),
  MineModel(MineCellType.Others, '扫一扫', 'images/icon_settings_scan@2x.png',
      (MineModel model) => {}),
  MineModel(MineCellType.Separator, null, null, null),
  MineModel(
      MineCellType.Others,
      '易钱包',
      'images/icon_yee_wallet@2x.png',
      (MineModel model) =>
          FlutterBoost.singleton.channel.sendEvent('showYeePayWallet', {}),
      needSeparatorLine: false,
      tipIcon: 'images/icon_setting_MFWallet_recommend@2x.png'),
  MineModel(MineCellType.Separator, null, null, null),
  MineModel(MineCellType.Others, '收藏', 'images/icon_setting_collect@2x.png',
      (MineModel model) => {},
      needSeparatorLine: true),
  MineModel(
      MineCellType.Others,
      '分享到微信',
      'images/icon_setting_wx@2x.png',
      (MineModel model) => WxSdk.wxShare(12,
          title: '我们都在使用擦肩，快来加入我们吧！',
          content: '和好友一起加入擦肩',
          url: 'https://download.youxi2018.cn'),
      needSeparatorLine: true),
  MineModel(MineCellType.Others, '帮助', 'images/icon_settings_about@2x.png',
      (MineModel model) => {},
      needSeparatorLine: true),
  MineModel(MineCellType.Others, '联系客服', 'images/icon_setting_service@2x.png',
      (MineModel model) => {},
      needSeparatorLine: true),
  MineModel(MineCellType.Separator, null, null, null),
  MineModel(MineCellType.Others, '设置', 'images/icon_settings_general@2x.png',
      (MineModel model) {
    /* 跳转设置页面 */
    FlutterBoost.singleton.open('setting', exts: {'animated': true});
  }),
];
