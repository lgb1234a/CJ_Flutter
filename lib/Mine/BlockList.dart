/// Created by Chenyn 2019-12-11
/// 黑名单
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class BlockListPage extends StatefulWidget {
  BlockListPage({Key key}) : super(key: key);

  @override
  _BlockListPageState createState() => _BlockListPageState();
}

class _BlockListPageState extends State<BlockListPage> {
  /// 被拉黑的用户
  List<UserInfo> _users = [];

  @override
  void initState() {
    super.initState();

    _loadBlockList();
  }

  /// 获取黑名单
  _loadBlockList() async {
    List<dynamic> ids = await NimSdkUtil.blockUserList();
    List<Future<UserInfo>> promises =
        ids.map((f) async => await NimSdkUtil.userInfoById(userId: f)).toList();
    List<UserInfo> users = await Future.wait(promises);
    setState(() {
      _users = users;
    });
  }

  /// 从黑名单移除
  _removeFromBlock(String userId) async {
    bool success = await NimSdkUtil.cancelBlockUser(userId);
    if (success) {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '移除成功'});
      _loadBlockList();
    } else {
      FlutterBoost.singleton.channel.sendEvent('showTip', {'text': '移除失败!'});
    }
  }

  /// 绘制item
  Widget _item(int idx) {
    UserInfo userInfo = _users[idx];
    return Container(
      height: 60,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          userInfo.avatarUrlString != null
              ? FadeInImage.assetNetwork(
                  image: userInfo.avatarUrlString,
                  width: 44,
                  placeholder: 'images/icon_avatar_placeholder@2x.png',
                )
              : Image.asset(
                  'images/icon_avatar_placeholder@2x.png',
                  width: 44,
                ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 5),),
          Text(userInfo.showName),
          Spacer(),
          CupertinoButton(
            child: Text('移除'),
            onPressed: () => _removeFromBlock(userInfo.userId),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: mainBgColor,
        appBar: AppBar(
          leading: new IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '黑名单',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: _users.isEmpty
            ? Center(
                child: Text('你的黑名单上暂无成员！'),
              )
            : ListView.separated(
                itemCount: _users.length,
                itemBuilder: (context, idx) => _item(idx),
                separatorBuilder: (context, idx) => Divider(
                  indent: 12,
                  height: 0.5,
                ),
              ),
      ),
    );
  }
}
