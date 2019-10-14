/**
 *  Created by chenyn on 2019-09-2
 *  通讯录成员model
 */

import 'package:azlistview/azlistview.dart';
import 'nim_searchInterface.dart';

/// 通讯录成员model
class ContactInfo extends ISuspensionBean implements CJSearchInterface {
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
}
