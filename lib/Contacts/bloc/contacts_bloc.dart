import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import './bloc.dart';
import 'package:azlistview/azlistview.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  List<ContactInfo> contactFunctions = [
    ContactInfo.fromJson({
      'showName': '新的朋友',
      'avatarUrlString': 'images/icon_contact_newfriend@2x.png'
    }),
    ContactInfo.fromJson({
      'showName': '群聊',
      'avatarUrlString': 'images/icon_contact_groupchat@2x.png'
    }),
    // ContactInfo.fromJson({
    //   'showName': '手机通讯录好友',
    //   'avatarUrlString': 'images/icon_contact_phone@2x.png'
    // })
  ];

  @override
  ContactsState get initialState => InitialContactsState();

  ContactsState previousState = InitialContactsState();
  @override
  Stream<ContactsState> mapEventToState(
    ContactsEvent event,
  ) async* {
    if (event is ContactsFetchEvent) {
      /* 获取数据 */
      List<ContactInfo> contacts = await loadData();

      previousState = ContactsLoaded(contacts);
      yield ContactsLoaded(contacts);
    }

    /* 跳转去搜索 */
    if (event is ContactsSearchEvent) {
      FlutterBoost.singleton
          .open('contact_searching', exts: {'animated': true});
    }

    /* 跳转个人信息页 */
    if (event is ContactTappedEvent) {
      ContactInfo info = event.contact;
      String userId = info.infoId;
      if (userId != null) {
        FlutterBoost.singleton.open('user_info',
            urlParams: {'user_id': userId},
            exts: {'animated': true});
      } else {
        if (contactFunctions.contains(info)) {
          if (contactFunctions.indexOf(info) == 0) {
            /// 跳转新朋友申请页面
            FlutterBoost.singleton.open('new_friend', exts: {'animated': true});
          } else if (contactFunctions.indexOf(info) == 1) {
            /// 跳转群聊列表
            FlutterBoost.singleton.open('group_chat', exts: {'animated': true});
          } else if (contactFunctions.indexOf(info) == 2) {
            /// 跳转手机通讯录好友
            // FlutterBoost.singleton.open('', exts: {'animated': true});
          }
        }
      }
    }

    /* 点击了索引 */
    if(event is SusTagChangedEvent) {
      yield ContactsTagChanged(event.tag);
    }
  }
}

/* 加载数据 */
Future<List<ContactInfo>> loadData() async {
  List<ContactInfo> friends = await NimSdkUtil.friends();
  _handleList(friends);

  return friends;
}

/* 排序 */
void _handleList(List<ContactInfo> list) {
  if (list == null || list.isEmpty) return;
  for (int i = 0, length = list.length; i < length; i++) {
    String pinyin = PinyinHelper.getPinyinE(list[i].showName);
    String tag = pinyin.substring(0, 1).toUpperCase();
    list[i].namePinyin = pinyin;
    if (RegExp("[A-Z]").hasMatch(tag)) {
      list[i].tagIndex = tag;
    } else {
      list[i].tagIndex = "#";
    }
  }

  //根据A-Z排序
  SuspensionUtil.sortListBySuspensionTag(list);
}
