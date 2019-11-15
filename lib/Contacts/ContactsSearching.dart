/**
 *  Created by chenyn on 2019-10-11
 *  通讯录搜索页
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'Model/ContactSearchDataSource.dart';
import 'package:nim_sdk_util/Model/nim_contactModel.dart';
import 'package:nim_sdk_util/Model/nim_teamModel.dart';
import 'package:nim_sdk_util/Model/nim_modelView.dart';
import 'package:flutter_boost/flutter_boost.dart';

class ContactsSearchingWidget extends StatefulWidget {
  // final Function cancel;
  // ContactsSearchingWidget(this.cancel);

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
  Widget _buildSearchBar() {
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
              child: SizedBox(
                  height: 40,
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
            ),
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
                  FlutterBoost.singleton.closeCurrent();
                },
              ),
            )
          ],
        ));
  }

  // tile
  Widget _buildTile(NimSearchContactViewModel model) {
    double itemHeight = 72.1;

    return SizedBox(
      height: itemHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Divider(
            height: 0.1,
            indent: 12,
          ),
          model.cell(() {
            if (model is ContactInfo) {
              /* 调用native，拉起选择联系人组件,创建群聊 */
              FlutterBoost.singleton.channel.sendEvent(
                  'sendMessage', {'session_id': model.infoId, 'type': 0});
            }

            if (model is TeamInfo) {
              /* 调用native，拉起选择联系人组件,创建群聊 */
              FlutterBoost.singleton.channel.sendEvent(
                  'sendMessage', {'session_id': model.teamId, 'type': 1});
            }
          })
        ],
      ),
    );
  }

  // 跳转到更多列表,把 _teams 或者 _contacts带过去
  void _pushSerachResultViewController(int type) {
    FocusScope.of(context).requestFocus(FocusNode());
    List models = [];
    if (type == 0) {
      models = _contacts.map((f) => f.toJson()).toList();
    }

    if (type == 1) {
      models = _teams.map((f) => f.toJson()).toList();
    }

    FlutterBoost.singleton.open('contact_search_result', urlParams: {
      'models': models,
      'keyword': _searchController.text,
      'type': type
    }, exts: {
      'animated': true
    }).then((Map alue) {});
  }

  // 更多
  Widget _buildMoreTile(int type) {
    return GestureDetector(
        onTap: () => _pushSerachResultViewController(type),
        child: Container(
          color: Colors.transparent,
          child: Column(
            children: <Widget>[
              Divider(
                indent: 12,
                height: 0.1,
              ),
              SizedBox(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flex(direction: Axis.horizontal, children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 12),
                      ),
                      Image.asset('images/icon_search_blue@2x.png',
                          width: 33, height: 33),
                      Text(type == 0 ? '更多联系人' : '更多群聊'),
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
          ),
        ));
  }

  // cell
  Widget _buildItem(NimSearchContactViewModel model) {
    if (model != null) {
      return _buildTile(model);
    }

    return SizedBox(
      height: 300,
      child: Center(
        child: Text('未匹配到相关数据类型~'),
      ),
    );
  }

  // section
  Widget _buildSection(int index) {
    List<Widget> contacts = _contacts.map((f) => _buildItem(f)).toList();
    List<Widget> teams = _teams.map((f) => _buildItem(f)).toList();

    // 添加更多入口
    if (contacts.length > 3) {
      contacts = contacts.sublist(0, 3);
      contacts.add(_buildMoreTile(0));
    }

    if (teams.length > 3) {
      teams = teams.sublist(0, 3);
      teams.add(_buildMoreTile(1));
    }

    contacts.insert(
      0,
      Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Container(
            height: 30,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Text('联系人'),
          )
        ],
      ),
    );
    teams.insert(
        0,
        Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              child: Text('群聊'),
            )
          ],
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
      height: 300,
      child: Center(
        child: Text('未搜索到相关信息~'),
      ),
    );
  }

  // search List
  Widget _searchList() {
    int itemCount = _contacts.length > 0 && _teams.length > 0 ? 2 : 1;
    return ListView.separated(
      itemCount: itemCount,
      itemBuilder: (context, idx) => _buildSection(idx),
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
          _buildSearchBar(),
          MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: Expanded(
                flex: 1,
                child: _searchList(),
              ))
        ],
      ),
    );
  }
}
