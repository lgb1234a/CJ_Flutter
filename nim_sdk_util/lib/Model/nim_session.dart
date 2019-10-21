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

  factory Session(Map params) {
    return Session._a(params['id'], params['type']);
  }
  
  Session._a(this.id, this.type);
}