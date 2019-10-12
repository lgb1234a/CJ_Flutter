/**
 *  Created by chenyn on 2019-10-12
 *  通讯录搜索数据源
 */
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'ContactModel.dart';
import 'CJSearchInterface.dart';
import 'TeamModel.dart';

class ContactSearchDataSource {
  bool isKeyContained(String key, String origin) {
    return origin.contains(key);
  }

  // 查找联系人
  Future<List<CJSearchInterface>> searchContactBy(String key) async {
    List<Map> friends = await NimSdkUtil.friends();
    List result = [];
    friends.forEach((e) {
      ContactInfo info = ContactInfo(e);

      if (isKeyContained(key, info.showName) ||
          isKeyContained(key, info.infoId) ||
          isKeyContained(key, info.namePinyin)) {
            info.keyword = key;
            result.add(info);
          }
    });
    return result;
  }

  // 查找群聊
  Future<List<CJSearchInterface>> searchGroupBy(String key) async {
    List<Map> teams = await NimSdkUtil.allMyTeams();
    List result = [];
    teams.forEach((t) async{
      TeamInfo team = TeamInfo(t);
      List<Map> members = await NimSdkUtil.teamMemberInfos(team.teamId);
      members.forEach((m){
        
      });
    });
    return result;
  }
}
