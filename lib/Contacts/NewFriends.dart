/// Created by Chenyn 2019-12-16
/// 新朋友页面
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import '../Base/CJUtils.dart';
import '../Base/CJEventBus.dart';

class NewFriendsPage extends StatefulWidget {
  NewFriendsPage({Key key}) : super(key: key);

  @override
  _NewFriendsPageState createState() => _NewFriendsPageState();
}

class _NewFriendsPageState extends State<NewFriendsPage> {
  Function _removeListener = () {};
  List<SystemNotification> _notifications = [];
  List<UserInfo> _userInfos = [];
  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _removeListener = FlutterBoost.singleton.channel
        .addEventListener('newNotification', (name, param) {
      /// 接收新的通知
      _notifications.add(SystemNotification.fromJson(param));
      setState(() {});
      return;
    });

    _fetchAllNotifications();
  }

  /// 获取通知
  _fetchAllNotifications() async {
    List<SystemNotification> notifications =
        await NimSdkUtil.fetchSystemNotifications();
    List<Future<UserInfo>> futureMap = notifications
        .map((f) async => await NimSdkUtil.userInfoById(userId: f.sourceID))
        .toList();
    _userInfos = await Future.wait(futureMap);
    setState(() {
      _notifications = notifications;
    });
  }

  /// 通知native，刷新通知状态
  _handledNotification(int notificationId, int handleStatus) {
    FlutterBoost.singleton.channel.sendEvent('handledNotification',
        {'notificationId': notificationId, 'handleStatus': handleStatus});
    _fetchAllNotifications();
  }

  _accept(SystemNotification notification) {
    if (notification.type == 0) {
      /// 同意进群申请
      NimSdkUtil.passApplyToTeam(notification.targetID, notification.sourceID)
          .then((status) {
        _handledNotification(notification.notificationId,
            NotificationHandleType.values.indexOf(status));
      });
    } else if (notification.type == 2) {
      /// 同意进群邀请
      NimSdkUtil.acceptInviteWithTeam(
              notification.targetID, notification.sourceID)
          .then((status) {
        _handledNotification(notification.notificationId,
            NotificationHandleType.values.indexOf(status));
      });
    } else if (notification.type == 5) {
      /// 同意加好友请求
      NimSdkUtil.requestFriend(notification.sourceID).then((status) {
        if(status == NotificationHandleType.NotificationHandleTypeOk) {
          /// 发送消息
          eventBus.fire(DeletedContact());
        }
        _handledNotification(notification.notificationId,
            NotificationHandleType.values.indexOf(status));
      });
    }
  }

  _reject(SystemNotification notification) {
    if (notification.type == 1) {
      /// 拒绝入群申请
      NimSdkUtil.rejectApplyToTeam(notification.targetID, notification.sourceID)
          .then((status) {
        _handledNotification(notification.notificationId,
            NotificationHandleType.values.indexOf(status));
      });
    } else if (notification.type == 3) {
      /// 拒绝进群邀请
      NimSdkUtil.rejectInviteWithTeam(
              notification.targetID, notification.sourceID)
          .then((status) {
        _handledNotification(notification.notificationId,
            NotificationHandleType.values.indexOf(status));
      });
    }
  }

  /// tile右侧视图
  Widget _tileTrailing(SystemNotification notification) {
    int handleType = notification.handleStatus;

    if (handleType == 0) {
      /// 待处理
      return Container(
        width: 132,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            CupertinoButton(
              child: Text(
                '同意',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () => _accept(notification),
            ),
            CupertinoButton(
              child: Text(
                '拒绝',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _reject(notification),
            )
          ],
        ),
      );
    } else {
      String statusDesc = '';
      if (handleType == 1) {
        statusDesc = '已同意';
      } else if (handleType == 2) {
        statusDesc = '已拒绝';
      } else if (handleType == 3) {
        statusDesc = '已过期';
      }
      return Text(statusDesc);
    }
  }

  /// 通知内容
  String _subTitle(int notificationType, int attachment) {
    switch (notificationType) {
      case 0:
        return '申请加入群';
      case 1:
        return '群 %@ 拒绝你加入';
      case 2:
        return '群 %@ 邀请你加入';
      case 3:
        return '拒绝了群 %@ 邀请';
      case 5:
        if (attachment == 1) {
          return '已添加你为好友';
        } else if (attachment == 2) {
          return '请求添加你为好友';
        } else if (attachment == 3) {
          return '通过了你的好友请求';
        } else if (attachment == 4) {
          return '拒绝了你的好友请求';
        }
        return '未知请求';
      default:
        return '未知请求';
    }
  }

  /// item绘制
  Widget _buildItem(context, idx) {
    UserInfo info = _userInfos[idx];
    SystemNotification notification = _notifications[idx];
    int type = notification.type;
    int attachment = notification.attachment;
    return ListTile(
      contentPadding: EdgeInsets.all(12),
      leading: info.avatarUrlString != null
          ? FadeInImage.assetNetwork(
              image: info.avatarUrlString,
              width: 44,
              placeholder: 'images/icon_avatar_placeholder@2x.png',
            )
          : Image.asset(
              'images/icon_avatar_placeholder@2x.png',
              width: 44,
            ),
      title: Text(info.showName ?? ''),
      subtitle: Text(_subTitle(type, attachment)),
      trailing: _tileTrailing(notification),
      onTap: () => FlutterBoost.singleton.open('user_info',
          urlParams: {'user_id': notification.sourceID},
          exts: {'animated': true}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            FlutterBoost.singleton.closeCurrent();
          },
        ),
        title: Text(
          '验证消息',
          style: TextStyle(color: blackColor),
        ),
        backgroundColor: mainBgColor,
        elevation: 0.01,
        iconTheme: IconThemeData.fallback(),
      ),
      body: ListView.separated(
        itemCount: _notifications.length,
        itemBuilder: _buildItem,
        separatorBuilder: (context, idx) => Divider(
          indent: 12,
          height: 0.5,
        ),
      ),
    );
  }
}
