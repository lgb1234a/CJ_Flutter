import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class ContactsearchingEvent {}

class NewContactSearchEvent extends ContactsearchingEvent {
  final String keyword;
  NewContactSearchEvent(this.keyword);
}

class TouchedMoreEvent extends ContactsearchingEvent {
  final int type; // 0: P2P  1:team
  final String keyword;
  final List<ContactInfo> contacts;
  final List<Team> groups;
  TouchedMoreEvent(this.type, this.keyword, this.contacts, this.groups);
}

class TouchedCellEvent extends ContactsearchingEvent {
  final Session session;
  TouchedCellEvent(this.session);
}

class CancelSearchingEvent extends ContactsearchingEvent {}
