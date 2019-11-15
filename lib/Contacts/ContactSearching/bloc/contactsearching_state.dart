import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class ContactsearchingState {}
  
class InitialContactsearchingState extends ContactsearchingState {}


class ContactsSearchingResult extends ContactsearchingState {
  final List<ContactInfo> contacts;
  final List<TeamInfo> groups;
  ContactsSearchingResult(this.contacts, this.groups);
}