/// Created by chenyn 2019-11-27
/// 群成员信息页

import 'package:flutter/material.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import '../Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:flutter/cupertino.dart';
import '../Login/LoginManager.dart';

class SessionMemberInfoWidget extends StatefulWidget {
  final Map params;
  SessionMemberInfoWidget(this.params);

  @override
  State<StatefulWidget> createState() {
    return SessionMemberInfoState();
  }
}

class SessionMemberInfoState extends State<SessionMemberInfoWidget> {
  TeamMemberInfo _memberInfo;
  UserInfo _userInfo;
  bool _isBlocked = false;
  double indent = 12;
  bool _isMe = false;
  bool _isMyFriend = false;

  @override
  void initState() {
    super.initState();

    fetchData();
  }

  void fetchData() async {
    _memberInfo = await NimSdkUtil.teamMemberInfoById(
        widget.params['team_id'], widget.params['member_id']);
    _userInfo =
        await NimSdkUtil.userInfoById(userId: widget.params['member_id']);
    _isBlocked = await NimSdkUtil.isUserBlocked(widget.params['member_id']);

    String me = await LoginManager().getAccid();
    _isMe = _memberInfo.userId == me;

    /// 由于bloc无法管理appBar的状态，所以在这里刷新状态
    _isMyFriend = await NimSdkUtil.isMyFriend(_memberInfo.userId);

    setState(() {});
  }

  _requestFriend() async {
    /// 添加好友
    NotificationHandleType type =
        await NimSdkUtil.requestFriend(_memberInfo.userId);
    if (type == NotificationHandleType.NotificationHandleTypeOk) {
      // 添加成功 刷新页面
      setState(() {
        _isMyFriend = true;
      });
    }
  }

  /// 操作拉黑/取消拉黑用户
  void changeUserBlockStatus(bool newValue) async {
    bool success;
    if (newValue) {
      success = await NimSdkUtil.blockUser(widget.params['member_id']);
    } else {
      success = await NimSdkUtil.cancelBlockUser(widget.params['member_id']);
    }

    if (success) {
      setState(() {
        _isBlocked = newValue;
      });
    }
  }

  /// 群成员信息
  Widget _infoHeader() {
    if (_memberInfo == null) {
      return Container();
    }

    return ListTile(
      leading: _userInfo.avatarUrlString != null
          ? FadeInImage.assetNetwork(
              image: _userInfo.avatarUrlString,
              width: 44,
              placeholder: 'images/icon_avatar_placeholder@2x.png',
            )
          : Image.asset(
              'images/icon_avatar_placeholder@2x.png',
              width: 44,
            ),
      title: Text(_userInfo.showName == null ? '' : _userInfo.showName),
      subtitle: Text(
        '擦肩号：' + _userInfo.cajianNo,
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  /// 昵称
  Widget _nickName() {
    return Cell(
        Text('群昵称'),
        Text(_memberInfo.nickName == null ? '未设置' : _memberInfo.nickName),
        () {});
  }

  /// 群成员身份类型
  Widget _memberType() {
    return Cell(Text('身份'), Text(_memberInfo.typeDesc), () {});
  }

  ///
  Widget _joinTime() {
    int dt = (_memberInfo.createTime * 1000).ceil();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dt);
    return Cell(Text('进群时间'), Text(date.toString()), () {});
  }

  /// 加入黑名单
  Widget _addBlockList() {
    return Cell(
        Text('加入黑名单'),
        CupertinoSwitch(
          value: _isBlocked,
          onChanged: (newValue) => changeUserBlockStatus(newValue),
        ),
        () {});
  }

  /* 发送消息按钮 */
  Widget _sendMsgSection() {
    if (_isMe) return Container();

    if (!_isMyFriend) {
      /// 不是朋友，显示添加添加好友
      return Container(
        padding: EdgeInsets.all(22),
        child: CupertinoButton.filled(
          padding: EdgeInsets.all(10),
          child: Text('添加到通讯录'),
          onPressed: _requestFriend,
        ),
      );
    }
    return GestureDetector(
      child: Container(
        height: 44,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Icon(Icons.send), Text('发消息')],
        ),
      ),
      onTap: () => FlutterBoost.singleton.open(
          'nativePage://android&iosPageName=CJSessionViewController',
          urlParams: {'id': widget.params['member_id'], 'type': 0},
          exts: {'animated': true}),
    );
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
            '成员信息',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: _memberInfo == null
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : ListView(
                children: <Widget>[
                  _infoHeader(),
                  Container(
                    height: 8,
                  ),
                  _nickName(),
                  Divider(
                    indent: indent,
                    height: 0.5,
                  ),
                  _memberType(),
                  Divider(
                    indent: indent,
                    height: 0.5,
                  ),
                  _joinTime(),
                  Divider(
                    indent: indent,
                    height: 0.5,
                  ),
                  _addBlockList(),
                  Container(
                    height: 20,
                  ),
                  _sendMsgSection()
                ],
              ),
      ),
    );
  }
}
