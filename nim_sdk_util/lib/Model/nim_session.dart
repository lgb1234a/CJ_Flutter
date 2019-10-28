/**
 * Created by chenyn on 2019-10-21
 * session Model
 */

enum SessionType {
  P2P,
  Team,
  Chatroom,
  SuperTeam
}

class Session {
  String id;
  int type;

  Session._a(this.id, this.type);

  // json -> model
  Session.fromJson(Map json)
      : id = json['id'],
        type = json['type'];
}
