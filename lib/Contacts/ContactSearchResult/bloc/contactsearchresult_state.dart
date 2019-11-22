import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class ContactsearchresultState {}
  
class InitialContactsearchresultState extends ContactsearchresultState {}


class ContactsSearchingResult extends ContactsearchresultState {
  final List<ContactInfo> contacts;
  final List<Team> groups;
  ContactsSearchingResult({this.contacts, this.groups});
}