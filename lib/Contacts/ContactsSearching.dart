/**
 *  Created by chenyn on 2019-10-11
 *  通讯录搜索页
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/CJUtils.dart';

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
  void searchTextChanged() {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSearchBar(context),
    );
  }
}
