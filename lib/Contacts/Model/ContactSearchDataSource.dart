/**
 *  Created by chenyn on 2019-10-12
 *  通讯录搜索数据源
 */
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/CJSearchInterface.dart';
import 'package:nim_sdk_util/ContactModel.dart';
import 'package:nim_sdk_util/TeamModel.dart';

class ContactSearchDataSource {
  static bool isKeyContained(String key, String origin) {
    return origin.contains(key);
  }

  // 查找联系人
  static Future<List<CJSearchInterface>> searchContactBy(String key) async {
    List<ContactInfo> friends = await NimSdkUtil.friends();
    List result = [];
    friends.forEach((e) {

      if (isKeyContained(key, e.showName) ||
          isKeyContained(key, e.infoId)) {
        e.keyword = key;
        result.add(e);
      }
    });
    return result;
  }

  // 查找群聊
  static Future<List<CJSearchInterface>> searchGroupBy(String key) async {
    List<TeamInfo> teams = await NimSdkUtil.allMyTeams();
    List result = [];
    teams.forEach((t) async {

      if(isKeyContained(key, t.teamName) || isKeyContained(key, t.teamId)){
        t.keyword = key;
        result.add(t);
      }
      List<TeamMemberInfo> members = await NimSdkUtil.teamMemberInfos(t.teamId);
      members.forEach((m) {

        if (isKeyContained(key, m.nickname) ||
            isKeyContained(key, m.userId)) {
              t.keyword = key;
              result.add(t);
            }
      });
    });
    return result;
  }
}
