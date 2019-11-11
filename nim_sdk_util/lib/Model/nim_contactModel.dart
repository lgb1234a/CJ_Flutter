/**
 *  Created by chenyn on 2019-09-2
 *  通讯录成员model
 */

import 'package:azlistview/azlistview.dart';
import 'nim_modelView.dart';
import 'package:flutter/material.dart';

/// 通讯录成员model
class ContactInfo extends ISuspensionBean implements NimSearchContactViewModel {
  String showName;
  String avatarUrlString;
  String infoId;
  String tagIndex;
  String namePinyin;

  // json -> model
  ContactInfo.fromJson(Map json)
      : showName = json['showName'],
        avatarUrlString = json['avatarUrlString'],
        infoId = json['infoId'],
        tagIndex = json['tagIndex'],
        namePinyin = json['namePinyin'],
        keyword = json['keyword'];

  @override
  String getSuspensionTag() => tagIndex;

  @override
  String keyword;

  @override
  Map toJson() {
    return {
      'showName': showName,
      'avatarUrlString': avatarUrlString,
      'infoId': infoId,
      'tagIndex': tagIndex,
      'namePinyin': namePinyin,
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

    if (showName != null && showName.contains(keyword)) {
      titleStart = showName.indexOf(keyword);
    }

    if (infoId != null && infoId.contains(keyword)) {
      subTitle = infoId;
      subTitleStart = subTitle.indexOf(keyword);
    }

    Widget title = titleStart == null
        ? Text(showName ?? '')
        : Text.rich(TextSpan(
            text: titleStart == 0 ? '' : showName.substring(titleStart),
            children: [
              TextSpan(
                  text: keyword, style: TextStyle(color: Colors.lightGreen)),
              TextSpan(
                  text: showName.length > titleStart + keyword.length
                      ? showName.substring(titleStart + keyword.length)
                      : '')
            ],
          ));

    Widget tile = subTitle != null
        ? ListTile(
            leading: avatarUrlString != null
                ? FadeInImage.assetNetwork(
                    image: avatarUrlString,
                    width: 44,
                    placeholder: 'images/icon_avatar_placeholder@2x.png',
                  )
                : Image.asset(
                    'images/icon_avatar_placeholder@2x.png',
                    width: 44,
                  ),
            title: title,
            subtitle: Text.rich(TextSpan(text: '用户id：', children: <TextSpan>[
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
            leading: avatarUrlString != null
                ? FadeInImage.assetNetwork(
                    image: avatarUrlString,
                    width: 44,
                    placeholder: 'images/icon_avatar_placeholder@2x.png',
                  )
                : Image.asset(
                    'images/icon_avatar_placeholder@2x.png',
                    width: 44,
                  ),
            title: title,
            onTap: onTap,
          );
    // 搜索联系人的结果页cell
    return tile;
  }
}
