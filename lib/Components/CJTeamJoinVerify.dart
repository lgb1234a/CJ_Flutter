/// Created by Chenyn 2019-12-19
/// 加入群聊验证页面
///
import 'package:flutter/material.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/cupertino.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';

class CJTeamJoinVerifyPage extends StatefulWidget {
  final Map params;
  CJTeamJoinVerifyPage({Key key, this.params}) : super(key: key);

  @override
  _CJTeamJoinVerifyPageState createState() => _CJTeamJoinVerifyPageState();
}

class _CJTeamJoinVerifyPageState extends State<CJTeamJoinVerifyPage> {
  String _teamId;
  TeamInfo _teamInfo;
  TextEditingController _verifyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _teamId = widget.params['teamId'];

    _fetchTeamInfo();
  }

  /// 获取群信息
  _fetchTeamInfo() async {
    TeamInfo info = await NimSdkUtil.teamInfoById(_teamId);
    setState(() {
      _teamInfo = info;
    });
  }

  /// 请求进群
  _requestJoinTeam(String verifyMsg) async {
    bool success = await NimSdkUtil.applyToTeam(_teamId, verifyMsg: verifyMsg);
    if (success) {
      FlutterBoost.singleton.open(
          'nativePage://androidPageName=com.youxi.chat.module.session.SessionHelper&iosPageName=CJSessionViewController',
          urlParams: {'id': _teamId, 'type': 1},
          exts: {'animated': true});
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
            '扫一扫',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            (_teamInfo != null && _teamInfo.avatarUrlString != null)
                ? FadeInImage.assetNetwork(
                    image: _teamInfo.avatarUrlString,
                    width: 44,
                    height: 44,
                    placeholder: 'images/icon_contact_groupchat@2x.png',
                  )
                : Image.asset(
                    'images/icon_contact_groupchat@2x.png',
                    width: 44,
                    height: 44,
                  ),
            Container(
              height: 8,
            ),
            Text(
              (_teamInfo == null || _teamInfo.showName == null
                  ? '获取失败'
                  : _teamInfo.showName),
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            Container(
              height: 8,
            ),
            Text(
              '群号：' +
                  (_teamInfo == null || _teamInfo.teamId == null
                      ? '获取失败'
                      : _teamInfo.teamId),
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Container(
              height: 8,
            ),
            CupertinoButton.filled(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('申请进群'),
              onPressed: () => cjDialog(context, '进群验证信息',
                  content: CupertinoTextField(
                    placeholder: '验证消息，可以不输入',
                    controller: _verifyController,
                    clearButtonMode: OverlayVisibilityMode.editing,
                  ),
                  handlers: [
                    () {
                      _requestJoinTeam(_verifyController.text.trim());
                    }
                  ],
                  handlerTexts: [
                    '确定'
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
