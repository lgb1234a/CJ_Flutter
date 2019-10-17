/**
 *  Created by chenyn on 2019-09-2
 *  通讯录成员model
 */

import 'package:azlistview/azlistview.dart';
import 'nim_searchInterface.dart';
import 'nim_modelView.dart';
import 'package:flutter/material.dart';

/// 通讯录成员model
class ContactInfo extends ISuspensionBean
    implements CJSearchInterface, NimSearchContactViewModel {
  String showName;
  String avatarUrlString;
  String infoId;
  String tagIndex;
  String namePinyin;

  factory ContactInfo(Map info) {
    return ContactInfo._a(info['showName'], info['avatarUrlString'],
        infoId: info['infoId'],
        tagIndex: info['tagIndex'],
        namePinyin: info['namePinyin']);
  }

  ContactInfo._a(this.showName, this.avatarUrlString,
      {this.infoId, this.tagIndex, this.namePinyin});

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
      'namePinyin': namePinyin
    };
  }

  @override
  Widget cell(Function onTap) {
    Widget avatar = Container(color: Colors.grey, width: 44, height: 44);
    String subTitle;
    int subTitleStart;
    int titleStart;
    if (showName.contains(keyword)) {
      titleStart = showName.indexOf(keyword);
    }

    if (infoId.contains(keyword)) {
      subTitle = infoId;
      subTitleStart = subTitle.indexOf(keyword);
    }

    Widget title = titleStart == null
                ? Text(showName)
                : Text.rich(TextSpan(
                    text: titleStart == 0 ? '' : showName.substring(titleStart),
                    children: [
                      TextSpan(
                          text: keyword,
                          style: TextStyle(color: Colors.lightGreen)),
                      TextSpan(
                          text: showName.length > titleStart + keyword.length
                              ? showName.substring(titleStart + keyword.length)
                              : '')
                    ],
                  ));

    Widget tile = subTitle != null
        ? ListTile(
            leading: avatarUrlString != null
                ? Image.network(avatarUrlString, width: 44, height: 44)
                : avatar,
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
                ? Image.network(avatarUrlString, width: 44, height: 44)
                : avatar,
            title: title,
            onTap: onTap,
          );
    // 搜索联系人的结果页cell
    return tile;
  }
}
