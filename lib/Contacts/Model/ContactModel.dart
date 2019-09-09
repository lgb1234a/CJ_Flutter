/**
 *  Created by chenyn on 2019-09-2
 *  通讯录成员model
 */

import 'package:azlistview/azlistview.dart';

/// 通讯录成员model
class ContactInfo extends ISuspensionBean {
  String showName;
  String avatarUrlString;
  String infoId;
  String tagIndex;
  String namePinyin;

  ContactInfo(this.showName, this.avatarUrlString,
      {this.infoId, this.tagIndex, this.namePinyin});

  @override
  String getSuspensionTag() => tagIndex;
}
