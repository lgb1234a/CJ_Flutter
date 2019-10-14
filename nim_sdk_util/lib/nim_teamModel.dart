/**
 *  Created by chenyn on 2019-10-12
 *  群model
 */

import 'nim_searchInterface.dart';

class TeamInfo implements CJSearchInterface {
  String teamId;
  String teamName;
  String teamAvatar;

  factory TeamInfo(Map info) {
    return TeamInfo._a(info['teamId'], info['teamName'], info['teamAvatar']);
  }

  TeamInfo._a(this.teamId, this.teamName, this.teamAvatar);

  @override
  String keyword;
}

class TeamMemberInfo implements CJSearchInterface {
  String teamId;
  String userId;
  String invitor;
  String inviterAccid;
  int type;
  String nickName;
  bool isMuted;
  double createTime;
  String customInfo;

  factory TeamMemberInfo(Map info) {
    return TeamMemberInfo._a(
        info['teamId'],
        info['userId'],
        info['invitor'],
        info['inviterAccid'],
        info['type'],
        info['nickName'],
        info['isMuted'],
        info['createTime'],
        info['customInfo']);
  }

  TeamMemberInfo._a(this.teamId, this.userId, this.invitor, this.inviterAccid,
      this.type, this.nickName, this.isMuted, this.createTime, this.customInfo);

  @override
  String keyword;
}
