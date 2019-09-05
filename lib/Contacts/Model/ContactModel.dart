/**
 *  Created by chenyn on 2019-09-2
 *  通讯录成员model
 */

import 'package:azlistview/azlistview.dart';
/// 通讯录成员model
class ContactInfo extends ISuspensionBean{
  String showName;
  String infoId;
  String avatarUrlString;
  String tagIndex;

  ContactInfo(this.showName, this.avatarUrlString, {this.infoId, this.tagIndex});

  @override
  String getSuspensionTag() => tagIndex;
}