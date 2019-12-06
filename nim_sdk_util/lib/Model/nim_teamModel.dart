/**
 *  Created by chenyn on 2019-10-12
 *  群model
 */
import 'nim_modelView.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class TeamInfo {
  /// 显示名
  String showName;

  /// 头像url
  String avatarUrlString;

  /// 头像图片
  Uint8List avatarImage;

  /// 群ID
  String teamId;

  /// 群名称
  String teamName;

  /// 群缩略头像
  /// @discussion 仅适用于使用云信上传服务进行上传的资源，否则无效。
  String thumbAvatarUrl;

  /// 群类型
  /// 普通群 = 0, 高级群 = 1
  int type;

  /// 群拥有者ID
  /// @discussion 普通群拥有者就是群创建者,但是高级群可以进行拥有信息的转让
  String owner;

  /// 群介绍
  String intro;

  /// 群公告
  String announcement;

  /// 群成员人数
  int memberNumber;

  /// 群等级
  /// @discussion 目前群人数主要是限制群人数上限
  int level;

  /// 群创建时间
  double createTime;

  /// 群验证方式
  /// @discussion 只有高级群有效
  int joinMode;

  /// 群邀请权限
  /// @discussion 只有高级群有效
  int inviteMode;

  /// 被邀请模式
  /// @discussion 只有高级群有效
  int beInviteMode;

  /// 修改群信息权限
  /// @discussion 只有高级群有效
  int updateInfoMode;

  /// 修改群客户端自定义字段权限
  /// @discussion 只有高级群有效
  int updateClientCustomMode;

  /// 群服务端自定义信息
  /// @discussion 应用方可以自行拓展这个字段做个性化配置,客户端不可以修改这个字段
  String serverCustomInfo;

  /// 群客户端自定义信息
  /// @discussion 应用方可以自行拓展这个字段做个性化配置,客户端可以修改这个字段
  String clientCustomInfo;

  /// 群消息通知状态
  /// @discussion 这个设置影响群消息的 APNS 推送
  int notifyStateForNewMsg;

  TeamInfo.fromJson(Map json)
      : showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        avatarImage = json['avatarImage'],
        teamId = json['teamId'],
        teamName = json['teamName'],
        thumbAvatarUrl = json['thumbAvatarUrl'],
        type = json['type'],
        owner = json['owner'],
        intro = json['intro'],
        announcement = json['announcement'],
        memberNumber = json['memberNumber'],
        level = json['level'],
        createTime = json['createTime'],
        joinMode = json['joinMode'],
        inviteMode = json['inviteMode'],
        beInviteMode = json['beInviteMode'],
        updateInfoMode = json['updateInfoMode'],
        updateClientCustomMode = json['updateClientCustomMode'],
        serverCustomInfo = json['serverCustomInfo'],
        clientCustomInfo = json['clientCustomInfo'],
        notifyStateForNewMsg = json['notifyStateForNewMsg'];
}

class Team implements NimSearchContactViewModel {
  String teamId;
  String teamName;
  String teamAvatar;

  Team._a(this.teamId, this.teamName, this.teamAvatar);

  // json -> model
  Team.fromJson(Map json)
      : teamId = json['teamId'],
        teamName = json['teamName'],
        teamAvatar = json['teamAvatar'],
        keyword = json['keyword'];

  @override
  String keyword;

  @override
  Map toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamAvatar': teamAvatar,
      'keyword': keyword
    };
  }

  @override
  Widget cell(Function onTap) {
    if (keyword == null) {
      return SizedBox();
    }

    String subTitle;
    int subTitleStart;
    int titleStart;
    if (teamName != null && teamName.contains(keyword)) {
      titleStart = teamName.indexOf(keyword);
    }

    if (teamId != null && teamId.contains(keyword)) {
      subTitle = teamId;
      subTitleStart = subTitle.indexOf(keyword);
    }

    Widget title = titleStart == null
        ? Text(teamName ?? '')
        : Text.rich(TextSpan(
            text: titleStart == 0 ? '' : teamName.substring(titleStart),
            children: [
              TextSpan(
                  text: keyword, style: TextStyle(color: Colors.lightGreen)),
              TextSpan(
                  text: teamName.length > titleStart + keyword.length
                      ? teamName.substring(titleStart + keyword.length)
                      : '')
            ],
          ));

    Widget tile = subTitle != null
        ? ListTile(
            leading: teamAvatar != null
                ? FadeInImage.assetNetwork(
                    image: teamAvatar,
                    width: 44,
                    placeholder: 'images/icon_contact_groupchat@2x.png',
                  )
                : Image.asset(
                    'images/icon_contact_groupchat@2x.png',
                    width: 44,
                  ),
            title: title,
            subtitle: Text.rich(TextSpan(text: '群id：', children: <TextSpan>[
              TextSpan(
                  text: subTitleStart != 0
                      ? subTitle.substring(0, subTitleStart)
                      : ''),
              TextSpan(
                  text: keyword, style: TextStyle(color: Colors.lightGreen)),
              TextSpan(
                  text: subTitle.length > subTitleStart + keyword.length
                      ? subTitle.substring(subTitleStart + keyword.length)
                      : '')
            ])),
            onTap: onTap,
          )
        : ListTile(
            leading: teamAvatar != null
                ? FadeInImage.assetNetwork(
                    image: teamAvatar ?? '',
                    width: 44,
                    placeholder: 'images/icon_contact_groupchat@2x.png',
                  )
                : Image.asset(
                    'images/icon_contact_groupchat@2x.png',
                    width: 44,
                  ),
            title: title,
            onTap: onTap,
          );
    // 搜索联系人的结果页cell
    return tile;
  }
}

class TeamMemberInfo extends NimSearchContactViewModel {
  /// 群id
  String teamId;

  /// 群成员id
  String userId;

  /// 邀请者id
  /// @dicusssion 此字段仅当该成员为自己时有效。不允许查看其他群成员的邀请者
  String invitor;

  /// 邀请者Accid
  /// @discussion 该属性值为@""或者自身Accid时均表示无邀请人，当为nil时需要主动调用接口去获取
  String inviterAccid;

  /// 群成员类型 0:普通 1:群主 2:管理员 3:申请加入用户
  int type;

  /// 群昵称
  String nickName;

  /// 被禁言
  bool isMuted;

  /// 进群时间
  double createTime;

  /// 新成员群自定义信息
  String customInfo;

  /// 群成员类型描述
  String get typeDesc {
    switch (type) {
      case 0:
        return '普通用户';
      case 1:
        return '群主';
      case 2:
        return '管理员';
      case 3:
        return '申请者';
      default:
        return '未知';
    }
  }

  TeamMemberInfo._a(this.teamId, this.userId, this.invitor, this.inviterAccid,
      this.type, this.nickName, this.isMuted, this.createTime, this.customInfo);

  // json -> model
  TeamMemberInfo.fromJson(Map json)
      : teamId = json['teamId'],
        userId = json['userId'],
        invitor = json['invitor'],
        inviterAccid = json['inviterAccid'],
        type = json['type'],
        nickName = json['nickName'],
        isMuted = json['isMuted'],
        createTime = json['createTime'],
        customInfo = json['customInfo'];

  @override
  String keyword;

  @override
  Map toJson() {
    return {
      'teamId': teamId,
      'userId': userId,
      'invitor': invitor,
      'inviterAccid': inviterAccid,
      'type': type,
      'nickName': nickName,
      'isMuted': isMuted,
      'createTime': createTime,
      'customInfo': customInfo
    };
  }

  @override
  Widget cell(Function onTap) {
    return SizedBox();
  }
}
