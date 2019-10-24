/**
 * Created by chenyn on 2019-10-21
 * session Model
 */

enum SessionType {
  SessionTypeP2P,
  SessionTypeTeam,
  SessionTypeChatroom,
  SessionTypeSuperTeam
}

class Session {
  String id;
  SessionType type;

  Session._a(this.id, this.type);

  // json -> model
  Session.fromJson(Map json)
      : id = json['id'],
        type = json['type'];
}
