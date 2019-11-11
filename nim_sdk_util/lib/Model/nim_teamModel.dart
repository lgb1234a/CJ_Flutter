/**
 *  Created by chenyn on 2019-10-12
 *  群model
 */
import 'nim_modelView.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

class TeamInfoFromId {
  String showName;
  String avatarUrlString;
  Uint8List avatarImage;

  TeamInfoFromId.fromJson(Map json)
      : showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        avatarImage = json['avatarImage'];
}

class TeamInfo implements NimSearchContactViewModel {
  String teamId;
  String teamName;
  String teamAvatar;

  TeamInfo._a(this.teamId, this.teamName, this.teamAvatar);

  // json -> model
  TeamInfo.fromJson(Map json)
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
            leading: FadeInImage.assetNetwork(
              image: teamAvatar ?? '',
              width: 44,
              placeholder: 'images/icon_contact_groupchat@2x.png',
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
            leading: FadeInImage.assetNetwork(
              image: teamAvatar ?? '',
              width: 44,
              placeholder: 'images/icon_contact_groupchat@2x.png',
            ),
            title: title,
            onTap: onTap,
          );
    // 搜索联系人的结果页cell
    return tile;
  }
}

class TeamMemberInfo extends NimSearchContactViewModel {
  String teamId;
  String userId;
  String invitor;
  String inviterAccid;
  int type;
  String nickName;
  bool isMuted;
  double createTime;
  String customInfo;

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
