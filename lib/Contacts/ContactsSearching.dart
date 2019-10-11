/**
 *  Created by chenyn on 2019-10-11
 *  通讯录搜索页
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ContactsSearchingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ContactsSearchingState();
  }
}

class ContactsSearchingState extends State<ContactsSearchingWidget> {
  int _searchBarHeight = 40;
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // search bar
  Widget _buildSearchBar(BuildContext context) {
    return SizedBox(
      height: _searchBarHeight.toDouble(),
      child: CupertinoTextField(
        controller: _searchController,
        placeholder: '搜索',
        prefix: Image.asset('images/icon_contact_search@2x.png'),
        prefixMode: OverlayVisibilityMode.always,
        padding: EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildSearchBar(context),
    );
  }
}
