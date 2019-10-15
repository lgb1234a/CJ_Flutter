import 'package:flutter/gestures.dart';
/**
 *  Created by chenyn on 2019-10-11
 *  通讯录搜索页
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'Model/ContactSearchDataSource.dart';
import 'package:nim_sdk_util/nim_contactModel.dart';
import 'package:nim_sdk_util/nim_teamModel.dart';
import 'package:nim_sdk_util/nim_searchInterface.dart';

class ContactsSearchingWidget extends StatefulWidget {
  final Function cancel;
  ContactsSearchingWidget(this.cancel);

  @override
  State<StatefulWidget> createState() {
    return ContactsSearchingState();
  }
}

class ContactsSearchingState extends State<ContactsSearchingWidget> {
  int _searchBarHeight = 50;
  TextEditingController _searchController = TextEditingController();
  List<ContactInfo> _contacts = [];
  List<TeamInfo> _teams = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      searchTextChanged();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 搜索文本变化
  void searchTextChanged() async {
    List<ContactInfo> contacts =
        await ContactSearchDataSource.searchContactBy(_searchController.text);
    List<TeamInfo> groups =
        await ContactSearchDataSource.searchGroupBy(_searchController.text);
    setState(() {
      _contacts = contacts;
      _teams = groups;
    });
  }

  // search bar
  Widget _buildSearchBar(BuildContext context) {
    double top = topPadding(context);
    double screenWidth = getSize(context).width;
    return Container(
        height: _searchBarHeight.toDouble() + top,
        color: Color(0xffe5e5e5),
        padding: EdgeInsets.fromLTRB(10, top, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
                height: 40,
                width: screenWidth - 90,
                child: CupertinoTextField(
                  controller: _searchController,
                  autofocus: true,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(3.0))),
                  placeholder: '搜索',
                  prefix: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Image.asset('images/icon_contact_search@2x.png'),
                  ),
                  prefixMode: OverlayVisibilityMode.always,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                )),
            SizedBox(
              width: 70,
              child: FlatButton(
                textColor: Colors.blue,
                child: Text(
                  '取消',
                  style: TextStyle(fontSize: 14),
                ),
                onPressed: () {
                  // 取消搜索
                  widget.cancel();
                },
              ),
            )
          ],
        ));
  }

  // tile
  Widget _buildTile(String avatarUrl, String showName, {String subTitle}) {
    double itemHeight = 72.1;
    Widget avatar = Container(color: Colors.grey, width: 44, height: 44);

    Widget tile = subTitle != null
        ? ListTile(
            leading: avatarUrl != null
                ? Image.network(avatarUrl, width: 44, height: 44)
                : avatar,
            title: Text(showName),
            subtitle: Text(subTitle),
            onTap: () {
              // 点击跳转到聊天
            },
          )
        : ListTile(
            leading: avatarUrl != null
                ? Image.network(avatarUrl, width: 44, height: 44)
                : avatar,
            title: Text(showName),
            onTap: () {
              // 点击跳转到聊天
            },
          );

    return SizedBox(
      height: itemHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Divider(
            height: 0.1,
            indent: 12,
          ),
          tile
        ],
      ),
    );
  }

  // 更多
  Widget _buildMoreTile(BuildContext context, String title) {
    double screenWidth = getSize(context).width;
    return GestureDetector(
        onTap: () {
          // 跳转到更多列表,把 _teams 或者 _contacts带过去
        },
        child: Column(
          children: <Widget>[
            Divider(
              indent: 12,
              height: 0.1,
            ),
            SizedBox(
              height: 60,
              width: screenWidth,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flex(direction: Axis.horizontal, children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 12),
                    ),
                    Image.asset('images/icon_search_blue@2x.png',
                        width: 33, height: 33),
                    Text(title),
                  ]),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                  ),
                  Padding(padding: EdgeInsets.only(right: 6)),
                ],
              ),
            )
          ],
        ));
  }

  // cell
  Widget _buildItem(BuildContext context, CJSearchInterface model) {
    if (model is ContactInfo) {
      return _buildTile(model.avatarUrlString, model.showName);
    }

    if (model is TeamInfo) {
      return _buildTile(model.teamAvatar, model.teamName);
    }

    return Center(
      child: Text('未匹配到相关数据类型！'),
    );
  }

  // section
  Widget _buildSection(BuildContext context, int index) {
    double screenWidth = getSize(context).width;
    List<Widget> contacts =
        _contacts.map((f) => _buildItem(context, f)).toList();
    List<Widget> teams = _teams.map((f) => _buildItem(context, f)).toList();

    // 添加更多入口
    if (contacts.length > 3) {
      contacts = contacts.sublist(0, 3);
      contacts.add(_buildMoreTile(context, '更多联系人'));
    }

    if (teams.length > 3) {
      teams = teams.sublist(0, 3);
      teams.add(_buildMoreTile(context, '更多群聊'));
    }

    contacts.insert(
        0,
        Container(
          height: 30,
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text('联系人'),
        ));
    teams.insert(
        0,
        Container(
          height: 30,
          width: screenWidth,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text('群聊'),
        ));

    // 先联系人，再群聊
    if (index == 0) {
      if (_contacts.length > 0) {
        return Column(
          children: contacts,
        );
      } else if (_teams.length > 0) {
        return Column(
          children: teams,
        );
      }
    } else if (index == 1 && _teams.length > 0) {
      return Column(
        children: teams,
      );
    }

    return SizedBox(
      width: screenWidth,
      height: 300,
      child: Center(
        child: Text('未搜索到相关信息~'),
      ),
    );
  }

  // search List
  Widget _searchList(BuildContext context) {
    int itemCount = _contacts.length > 0 && _teams.length > 0 ? 2 : 1;
    return ListView.separated(
      itemCount: itemCount,
      itemBuilder: (context, idx) => _buildSection(context, idx),
      separatorBuilder: (context, idx) {
        return Container(
          height: 9,
          color: Color(0xffe5e5e5),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _buildSearchBar(context),
          MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: Expanded(
                flex: 1,
                child: _searchList(context),
              ))
        ],
      ),
    );
  }
}
