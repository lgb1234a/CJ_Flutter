/**
 *  Created by chenyn on 2019-06-28
 *  通讯录
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:azlistview/azlistview.dart';
import 'ContactsSearching.dart';
import 'package:nim_sdk_util/Model/nim_contactModel.dart';

class ContactsWidget extends StatefulWidget {
  final Map params;
  final String channelName;

  ContactsWidget(this.params, this.channelName);
  ContactsState createState() {
    return new ContactsState();
  }
}

class ContactsState extends State<ContactsWidget> {
  List<ContactInfo> _contacts = List();
  List<ContactInfo> _contactFunctions = List();
  MethodChannel platform;
  int _suspensionHeight = 40;
  int _itemHeight = 60;
  int _searchBarHeight = 60;
  String _suspensionTag = "";
  bool _inSeraching = false;

  @override
  void initState() {
    super.initState();
    loadData();
    platform = MethodChannel(widget.channelName);
    platform.setMethodCallHandler(handler);
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
  }

  void loadData() async {
    List friends = await NimSdkUtil.friends();
    friends.forEach((f) {
      _contacts.add(f);
    });
    _handleList(_contacts);
  }

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
    SuspensionUtil.sortListBySuspensionTag(_contacts);

    _contactFunctions.addAll([
      ContactInfo({
        'showName': '新的朋友',
        'avatarUrlString': 'images/icon_contact_newfriend@2x.png'
      }),
      ContactInfo({
        'showName': '群聊',
        'avatarUrlString': 'images/icon_contact_groupchat@2x.png'
      }),
      ContactInfo({
        'showName': '手机通讯录好友',
        'avatarUrlString': 'images/icon_contact_phone@2x.png'
      })
    ]);

    setState(() {});
  }

  void _onSusTagChanged(String tag) {
    setState(() {
      _suspensionTag = tag;
    });
  }

  Widget _buildSusWidget(String susTag) {
    if (susTag == null || susTag == '') {
      return Container();
    }

    return Container(
      height: _suspensionHeight.toDouble(),
      padding: const EdgeInsets.only(left: 15.0),
      color: Color(0xfff3f4f5),
      alignment: Alignment.centerLeft,
      child: Text(
        '$susTag',
        softWrap: false,
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xff999999),
        ),
      ),
    );
  }

  // search bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
        height: _searchBarHeight.toDouble(),
        color: appBarColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: SizedBox(
          height: 40,
          child: CupertinoButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            color: whiteColor,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset('images/icon_contact_search@2x.png'),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                ),
                Text(
                  '搜索',
                  style: TextStyle(color: Color(0xe5e5e5ff)),
                )
              ],
            ),
            onPressed: () {
              // 切换搜索状态
              setState(() {
                _inSeraching = true;
              });
            },
          ),
        ));
  }

  // list header
  Widget _buildHeader(BuildContext context) {
    List<Widget> headerItems = _contactFunctions.map((e) {
      return _buildListItem(context, e);
    }).toList();
    // 插入search bar
    headerItems.insert(0, _buildSearchBar(context));
    return Column(
      children: headerItems,
    );
  }

  // cell
  Widget _buildListItem(BuildContext context, ContactInfo model) {
    String susTag = model.getSuspensionTag();
    Size screenSize = getSize(context);
    // 头像
    Widget avatar = Container(color: Colors.grey, width: 44, height: 44);
    if (model.avatarUrlString != null) {
      if (model.avatarUrlString.contains('images/', 0)) {
        avatar = Image.asset(model.avatarUrlString, width: 44, height: 44);
      } else {
        avatar = Image.network(model.avatarUrlString, width: 44);
      }
    }
    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        Container(
            height: _itemHeight.toDouble(),
            width: screenSize.width,
            child: Row(
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                avatar,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                ),
                Text(model.showName),
                Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
              ],
            ))
      ],
    );
  }

  // 非搜索状态下的通讯录
  Widget _buildContacts(BuildContext context) {
    double bp = double.parse(widget.params['bottom_padding']);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            '通讯录',
            style: TextStyle(color: Color(0xFF141414)),
          ),
          backgroundColor: appBarColor,
          elevation: 0.01,
          brightness: Brightness.light,
        ),
        body: AzListView(
          padding: EdgeInsets.fromLTRB(0, 0, 0, bp),
          header: AzListViewHeader(
              height: _itemHeight * _contactFunctions.length + _searchBarHeight,
              builder: (context) {
                return _buildHeader(context);
              }),
          data: _contacts,
          itemBuilder: (context, model) => _buildListItem(context, model),
          suspensionWidget: _buildSusWidget(_suspensionTag),
          isUseRealIndex: true,
          itemHeight: _itemHeight,
          suspensionHeight: _suspensionHeight,
          onSusTagChanged: _onSusTagChanged,
        ));
  }

  void cancelSearch() {
    setState(() {
      _inSeraching = false;
    });
  }

  // 通讯录搜索页
  Widget _buildContactsInSearching(BuildContext context) {
    return ContactsSearchingWidget(cancelSearch, platform);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: _inSeraching
            ? _buildContactsInSearching(
                context,
              )
            : _buildContacts(context));
  }
}
