/**
 * create by chenyn 2019-11-8
 * 联系人设置页面
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import '../../Base/CJUtils.dart';

class ContactSetting extends StatefulWidget {
  final Map params;
  ContactSetting(this.params);

  @override
  State<StatefulWidget> createState() {
    return ContactSettingState();
  }
}

class ContactSettingState extends State<ContactSetting> {
  String _userId;
  bool _inBlock = false;
  bool _allowMsgNotify = true;
  @override
  void initState() {
    super.initState();
    _userId = widget.params['userId'];

    _fetchSwitchStatus();
  }

  /// 获取状态
  _fetchSwitchStatus() async {
    bool allowNotify = await NimSdkUtil.isNotifyForNewMsg(Session(_userId, 0));
    bool inBlock = await NimSdkUtil.isUserBlocked(_userId);

    setState(() {
      _inBlock = inBlock;
      _allowMsgNotify = allowNotify;
    });
  }

  ///
  _recommendContact() {
    return Cell(
        Text('把TA推荐给朋友'),
        Icon(
          Icons.arrow_forward_ios,
        ), () {
      /// TODO:
    });
  }

  ///
  Widget _block() {
    return Cell(
        Text('黑名单'),
        CupertinoSwitch(
          value: _inBlock,
          onChanged: (newValue) async {
            bool success = false;
            if (newValue) {
              success = await NimSdkUtil.blockUser(_userId);
            } else {
              success = await NimSdkUtil.cancelBlockUser(_userId);
            }

            if (success) {
              setState(() {
                _inBlock = newValue;
              });
            }
          },
        ),
        null);
  }

  ///
  Widget _msgNotify() {
    return Cell(
        Text('新消息通知'),
        CupertinoSwitch(
          value: _allowMsgNotify,
          onChanged: (newValue) async {
            bool success =
                await NimSdkUtil.allowUserMsgNotify(_userId, newValue);

            if (success) {
              setState(() {
                _allowMsgNotify = newValue;
              });
            }
          },
        ),
        null);
  }

  /// 删除联系人
  _deleteContact() async {
    bool success = await NimSdkUtil.deleteContact(_userId);
    if (success) {
      FlutterBoost.singleton.channel.sendEvent('popToRootPage', {});
      // FlutterBoost.singleton.channel.sendEvent('refreshContacts', {});
    }
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
            '资料设置',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          children: <Widget>[
            _recommendContact(),
            Container(
              height: 8,
            ),
            _block(),
            Divider(
              indent: 12,
              height: 0.5,
            ),
            _msgNotify(),
            Divider(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: 40,
              child: CupertinoButton.filled(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '删除',
                    ),
                  ],
                ),
                onPressed: () {
                  cjSheet(context, '确定要删除该好友吗？',
                      content: Text(
                        '删除后无法恢复,请谨慎操作',
                        style: TextStyle(color: Colors.red),
                      ),
                      handlers: [_deleteContact],
                      handlerTexts: ['确定']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
