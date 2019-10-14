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
    return Container(
        height: _searchBarHeight.toDouble() + top,
        color: Color(0xffe5e5e5),
        padding: EdgeInsets.fromLTRB(10, top, 10, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: CupertinoTextField(
                controller: _searchController,
                autofocus: true,
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
              ),
            ),
            Container(
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

  // cell
  Widget _buildItem(BuildContext context, CJSearchInterface model) {
    Widget avatar = Container(color: Colors.grey, width: 44, height: 44);
    double itemHeight = 72.1;
    if (model is ContactInfo) {
      return SizedBox(
        height: itemHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Divider(
              height: 0.1,
              indent: 12,
            ),
            ListTile(
              leading: model.avatarUrlString != null
                  ? Image.network(model.avatarUrlString, width: 44, height: 44)
                  : avatar,
              title: Text(model.showName),
              subtitle: Text(''), // 显示匹配的关键词
              onTap: () {
                // 点击跳转到个人信息
              },
            )
          ],
        ),
      );
    }

    if (model is TeamInfo) {
      return SizedBox(
        height: itemHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Divider(
              height: 0.1,
              indent: 12,
            ),
            ListTile(
              leading: model.teamAvatar != null
                  ? Image.network(model.teamAvatar, width: 44, height: 44)
                  : avatar,
              title: Text(model.teamName),
              subtitle: Text(''), // 显示匹配的关键词
              onTap: () {
                // 点击跳转到群聊
              },
            )
          ],
        ),
      );
    }

    return Center(
      child: Text('未匹配到相关数据类型！'),
    );
  }

  Widget _buildSection(BuildContext context, int index) {
    double screenWidth = getSize(context).width;
    List<Widget> contacts =
        _contacts.map((f) => _buildItem(context, f)).toList();
    List<Widget> teams = _teams.map((f) => _buildItem(context, f)).toList();

    contacts.insert(
        0,
        Container(
          height: 30,
          width: screenWidth,
          padding: EdgeInsetsDirectional.only(start: 12),
          child: Text('联系人'),
        ));
    teams.insert(
        0,
        Container(
          height: 30,
          width: screenWidth,
          padding: EdgeInsetsDirectional.only(start: 12),
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

    return Center(
      child: Text('未搜索到相关信息~'),
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
          Expanded(
            flex: 1,
            child: _searchList(context),
          )
        ],
      ),
    );
  }
}
