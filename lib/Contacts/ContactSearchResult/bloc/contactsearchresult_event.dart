import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class ContactsearchresultEvent {}

class TappedCellEvent extends ContactsearchresultEvent {
  final Session session;
  TappedCellEvent(this.session);
}

class CancelSearchingEvent extends ContactsearchresultEvent {}

class NewContactSearchEvent extends ContactsearchresultEvent {
  final int type;
  final String keyword;
  NewContactSearchEvent(this.type, this.keyword);
}
