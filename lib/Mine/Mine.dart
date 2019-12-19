/**
 *  Created by chenyn on 2019-06-28
 *  我的
 */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:wx_sdk/wx_sdk.dart';
import 'package:cajian/Base/CJUtils.dart';
import '../Base/CJEventBus.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class MineWidget extends StatefulWidget {
  final Map params;
  MineWidget(this.params);

  MineState createState() {
    return MineState();
  }
}

class MineState extends State<MineWidget> {
  StreamSubscription _streamSubscription;
  UserInfo _info;

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    /// 监听刷新事件
    _streamSubscription = eventBus.on<UpdatedUserInfo>().listen((e) {
      _mineInfo();
    });

    _mineInfo();
  }

  /// 获取信息
  _mineInfo() async {
    UserInfo info = await NimSdkUtil.userInfoById();
    setState(() {
      _info = info;
    });
  }

  /// 个人信息
  Widget _infoSection() {
    return GestureDetector(
      child: Container(
          height: 103,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              (_info != null && _info.avatarUrlString != null)
                  ? FadeInImage.assetNetwork(
                      image: _info.avatarUrlString,
                      width: 44,
                      placeholder: 'images/icon_avatar_placeholder@2x.png',
                    )
                  : Image.asset(
                      'images/icon_avatar_placeholder@2x.png',
                      width: 44,
                    ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (_info != null && _info.showName != null)
                        ? _info.showName
                        : '',
                    style: TextStyle(fontSize: 17, color: blackColor),
                  ),
                  Text(
                    '擦肩号：' +
                        ((_info != null && _info.showName != null)
                            ? _info.cajianNo
                            : ''),
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9B9B9B),
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ],
              )),
              Image.asset(
                'images/icon_settings_gray_qr@2x.png',
                width: 14,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              new Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
              ),
            ],
          )),
      onTap: () =>
          FlutterBoost.singleton.open('mine_info', exts: {'animated': true}),
    );
  }

  ///
  Widget _cell(String icon, String title, Function tap, {String tipIcon}) {
    return GestureDetector(
      child: Container(
        height: 48,
        color: Colors.white,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            new Image.asset(icon),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
            ),
            new Text(
              title,
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
            ),
            tipIcon != null ? new Image.asset(tipIcon) : Container(),
            Spacer(),
            new Icon(
              Icons.arrow_forward_ios,
              size: 16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
        ),
      ),
      onTap: tap,
    );
  }

  @override
  Widget build(BuildContext context) {
    double bp = widget.params['bottom_padding'] ?? 0;

    Widget mineTable = ListView(
      padding: EdgeInsets.only(bottom: bp),
      children: <Widget>[
        _infoSection(),
        Container(
          height: 8,
        ),
        _cell(
            'images/icon_settings_scan@2x.png',
            '扫一扫',
            () => FlutterBoost.singleton
                .open('qr_scan', exts: {'animated': true}),
            tipIcon: null),
        Container(
          height: 8,
        ),
        _cell(
            'images/icon_yee_wallet@2x.png',
            '易钱包',
            () => FlutterBoost.singleton.channel
                .sendEvent('showYeePayWallet', {}),
            tipIcon: 'images/icon_setting_MFWallet_recommend@2x.png'),
        Container(
          height: 8,
        ),
        _cell('images/icon_setting_collect@2x.png', '收藏',
            () => cjDialog(context, '易宝版暂不支持收藏功能，敬请期待～')),
        Divider(
          indent: 16.0,
          height: 0.5,
        ),
        _cell(
            'images/icon_setting_wx@2x.png',
            '分享到微信',
            () => WxSdk.wxShare(12,
                title: '我们都在使用擦肩，快来加入我们吧！',
                content: '和好友一起加入擦肩',
                url: 'https://download.youxi2018.cn')),
        Divider(
          indent: 16.0,
          height: 0.5,
        ),
        _cell(
            'images/icon_settings_about@2x.png',
            '帮助',
            () => FlutterBoost.singleton.open('web_view', urlParams: {
                  'url': 'https://help.youxi2018.cn/app/help/index.html', 'title': '擦肩帮助文档'
                })),
        Divider(
          indent: 16.0,
          height: 0.5,
        ),
        _cell('images/icon_setting_service@2x.png', '联系客服',
            () => cjDialog(context, '易宝版暂不支持客服功能，敬请期待～')),
        Container(
          height: 8,
        ),
        _cell(
            'images/icon_settings_general@2x.png',
            '设置',
            () => FlutterBoost.singleton
                .open('setting', exts: {'animated': true})),
      ],
    );

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.01,
          brightness: Brightness.light,
        ),
        body: Container(
          color: mainBgColor,
          child: mineTable,
        ),
      ),
    );
  }
}
