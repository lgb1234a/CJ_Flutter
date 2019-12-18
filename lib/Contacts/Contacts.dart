/**
 *  Created by chenyn on 2019-06-28
 *  通讯录
 */
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_contactModel.dart';
import 'bloc/bloc.dart';

class ContactsWidget extends StatefulWidget {
  final Map params;

  ContactsWidget(this.params);
  ContactsWidgetState createState() {
    return new ContactsWidgetState();
  }
}

class ContactsWidgetState extends State<ContactsWidget> {
  int _suspensionHeight = 40;
  int _itemHeight = 60;
  int _searchBarHeight = 60;
  String _suspensionTag = "";

  ContactsBloc _bloc;

  @override
  void initState() {
    super.initState();

    FlutterBoost.singleton.channel.addEventListener('refreshContacts',
        (name, notify) {
      /// TODO:
      print('接受到了通知 ========================||||||');
      _bloc.add(ContactsFetchEvent());
      return Future.value(true);
    });
  }

  /* 置顶section header */
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
  Widget _buildSearchBar() {
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
            onPressed: () => _bloc.add(ContactsSearchEvent()),
          ),
        ));
  }

  // list header
  Widget _buildHeader() {
    List<Widget> headerItems = _bloc.contactFunctions.map((e) {
      return _buildListItem(e);
    }).toList();
    // 插入search bar
    headerItems.insert(0, _buildSearchBar());
    return Column(
      children: headerItems,
    );
  }

  // cell
  Widget _buildListItem(ContactInfo model) {
    String susTag = model.getSuspensionTag();
    // 头像
    Widget avatar;
    if (model.avatarUrlString != null &&
        model.avatarUrlString.contains('images/', 0)) {
      avatar = Image.asset(model.avatarUrlString, width: 44, height: 44);
    } else {
      avatar = model.avatarUrlString != null
          ? FadeInImage.assetNetwork(
              image: model.avatarUrlString,
              width: 44,
              placeholder: 'images/icon_avatar_placeholder@2x.png',
            )
          : Image.asset(
              'images/icon_avatar_placeholder@2x.png',
              width: 44,
            );
    }

    return Column(
      children: <Widget>[
        Offstage(
          offstage: model.isShowSuspension != true,
          child: _buildSusWidget(susTag),
        ),
        GestureDetector(
            onTap: () => _bloc.add(ContactTappedEvent(model)),
            child: Container(
              height: _itemHeight.toDouble(),
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  avatar,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                  Text(model.alias ?? model?.showName),
                  Spacer(),
                ],
              ),
            ))
      ],
    );
  }

  // 非搜索状态下的通讯录
  Widget _buildContacts() {
    double bp = widget.params['bottom_padding'];

    return MaterialApp(
        home: BlocProvider<ContactsBloc>(
      create: (BuildContext context) {
        _bloc = ContactsBloc()..add(ContactsFetchEvent());
        return _bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '通讯录',
            style: TextStyle(color: Color(0xFF141414)),
          ),
          backgroundColor: appBarColor,
          elevation: 0.01,
          brightness: Brightness.light,
        ),
        body: BlocBuilder<ContactsBloc, ContactsState>(
          builder: (context, state) {
            if (state is ContactsLoaded || state is ContactsTagChanged) {
              if (state is ContactsTagChanged) {
                // 点击了索引需要调整
                _suspensionTag = state.tag;
              }

              ContactsLoaded previous;
              if (_bloc.previousState is ContactsLoaded) {
                previous = _bloc.previousState;
              }
              /* 加载完成 */
              return AzListView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, bp),
                header: AzListViewHeader(
                    height: _itemHeight * _bloc.contactFunctions.length +
                        _searchBarHeight,
                    builder: (context) {
                      return _buildHeader();
                    }),
                data: state is ContactsLoaded
                    ? state.contacts
                    : previous.contacts,
                itemBuilder: (context, model) => _buildListItem(model),
                suspensionWidget: _buildSusWidget(_suspensionTag),
                isUseRealIndex: true,
                itemHeight: _itemHeight,
                suspensionHeight: _suspensionHeight,
                onSusTagChanged: (tag) => _bloc.add(SusTagChangedEvent(tag)),
              );
            }

            return Center(
              child: CupertinoActivityIndicator(),
            );
          },
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _buildContacts());
  }
}
