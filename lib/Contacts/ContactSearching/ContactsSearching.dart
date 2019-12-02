/**
 *  Created by chenyn on 2019-10-11
 *  通讯录搜索页
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:nim_sdk_util/Model/nim_contactModel.dart';
import 'package:nim_sdk_util/Model/nim_teamModel.dart';
import 'package:nim_sdk_util/Model/nim_modelView.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';

class ContactsSearchingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactsSearchingState();
  }
}

class ContactsSearchingState extends State<ContactsSearchingWidget> {
  int _searchBarHeight = 50;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<ContactInfo> _contacts = [];
  List<Team> _teams = [];

  ContactsearchingBloc _bloc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => _bloc.add(NewContactSearchEvent(_searchController.text)));

    _scrollController.addListener(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                onPressed: () => _bloc.add(CancelSearchingEvent()),
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
            Session session;
            if (model is ContactInfo) {
              session = Session(model.infoId, 0);
            }

            if (model is Team) {
              session = Session(model.teamId, 1);
            }

            // 点击了cell
            _bloc.add(TouchedCellEvent(session));
          })
        ],
      ),
    );
  }

  // 更多
  Widget _buildMoreTile(int type) {
    return GestureDetector(
        onTap: () {
          _bloc.add(TouchedMoreEvent(
              type, _searchController.text, _contacts, _teams));
          // 隐藏键盘
          FocusScope.of(context).requestFocus(FocusNode());
        },
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
      controller: _scrollController,
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
    return MaterialApp(
        home:
            BlocProvider<ContactsearchingBloc>(builder: (BuildContext context) {
      _bloc = ContactsearchingBloc();
      return _bloc;
    }, child: Scaffold(
      body: BlocBuilder<ContactsearchingBloc, ContactsearchingState>(
        builder: (context, state) {
          if (state is ContactsSearchingResult) {
            _contacts = state.contacts;
            _teams = state.groups;
          }

          return Column(
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
          );
        },
      ),
    )));
  }
}
