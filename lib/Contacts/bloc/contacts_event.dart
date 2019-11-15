import 'package:meta/meta.dart';
import 'package:nim_sdk_util/Model/nim_contactModel.dart';

@immutable
abstract class ContactsEvent {}

/* 初始化通讯录数据 */
class ContactsFetchEvent extends ContactsEvent{}

/* 点击搜索 */
class ContactsSearchEvent extends ContactsEvent{}

/* 点击跳转 */
class ContactTappedEvent extends ContactsEvent {
  final ContactInfo contact;
  ContactTappedEvent(this.contact);
}

/* 点击了索引 */
class SusTagChangedEvent extends ContactsEvent {
  final String tag;
  SusTagChangedEvent(this.tag);
}