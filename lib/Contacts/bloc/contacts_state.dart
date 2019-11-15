import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

@immutable
abstract class ContactsState {}
  
class InitialContactsState extends ContactsState {}

class ContactsLoaded extends ContactsState {
  final List<ContactInfo> contacts;
  ContactsLoaded(this.contacts);
}

class ContactsTagChanged extends ContactsState {
  final String tag;
  ContactsTagChanged(this.tag);
}
