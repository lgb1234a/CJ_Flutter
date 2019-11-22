import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import './bloc.dart';
import '../../Model/ContactSearchDataSource.dart';

class ContactsearchingBloc
    extends Bloc<ContactsearchingEvent, ContactsearchingState> {
  @override
  ContactsearchingState get initialState => InitialContactsearchingState();

  @override
  Stream<ContactsearchingState> mapEventToState(
    ContactsearchingEvent event,
  ) async* {
    if (event is NewContactSearchEvent) {
      /* 新搜索关键词 */
      List<ContactInfo> contacts =
          await ContactSearchDataSource.searchContactBy(event.keyword);
      List<Team> groups =
          await ContactSearchDataSource.searchGroupBy(event.keyword);
      yield ContactsSearchingResult(contacts, groups);
    }

    if (event is TouchedMoreEvent) {
      /* 跳转更多 */
      pushSerachResultViewController(
          event.type, event.keyword, event.contacts, event.groups);
    }

    if (event is TouchedCellEvent) {
      /* 点击联系人 */
      FlutterBoost.singleton.channel.sendEvent('sendMessage',
          {'session_id': event.session.id, 'type': event.session.type});
    }

    if (event is CancelSearchingEvent) {
      /* 取消搜索 */
      FlutterBoost.singleton.closeCurrent();
    }
  }
}

// 跳转到更多列表,把 teams 或者 contacts带过去
void pushSerachResultViewController(int type, String keyword,
    List<ContactInfo> contacts, List<Team> groups) {
  List models = [];
  if (type == 0) {
    models = contacts.map((f) => f.toJson()).toList();
  }

  if (type == 1) {
    models = groups.map((f) => f.toJson()).toList();
  }

  FlutterBoost.singleton.open('contact_search_result',
      urlParams: {'models': models, 'keyword': keyword, 'type': type},
      exts: {'animated': true}).then((Map alue) {});
}
