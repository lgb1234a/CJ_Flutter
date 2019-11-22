import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import './bloc.dart';
import '../../Model/ContactSearchDataSource.dart';

class ContactsearchresultBloc
    extends Bloc<ContactsearchresultEvent, ContactsearchresultState> {
  @override
  ContactsearchresultState get initialState =>
      InitialContactsearchresultState();

  @override
  Stream<ContactsearchresultState> mapEventToState(
    ContactsearchresultEvent event,
  ) async* {
    if (event is NewContactSearchEvent) {
      /* 新搜索关键词 */
      if (event.type == 0) {
        List<ContactInfo> contacts = await ContactSearchDataSource.searchContactBy(event.keyword);
        yield ContactsSearchingResult(contacts: contacts);
      }
      if (event.type == 1) {
        List<Team> groups = await ContactSearchDataSource.searchGroupBy(event.keyword);
        yield ContactsSearchingResult(groups: groups);
      }
    }

    /* 点击cell */
    if (event is TappedCellEvent) {
      FlutterBoost.singleton.channel.sendEvent('sendMessage',
          {'session_id': event.session.id, 'type': event.session.type});
    }

    if (event is CancelSearchingEvent) {
      /* 取消搜索 */
      FlutterBoost.singleton.closeCurrent();
    }
  }
}
