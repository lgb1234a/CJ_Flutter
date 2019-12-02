/**
 * Created by chenyn on 2019-10-15
 * 通讯录搜索列表页（从点击更多 跳转过来）
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:nim_sdk_util/Model/nim_modelView.dart';
import 'bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const double searchBarHeight = 70;

// 搜索框 app bar
class ContactSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final String keyword;
  final Function cancel;
  final Function searchCallBack;
  ContactSearchBar(this.keyword, this.cancel, this.searchCallBack);

  @override
  ContactSearchBarState createState() => ContactSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(searchBarHeight);
}

class ContactSearchBarState extends State<ContactSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 初始化搜索框文案
    _searchController.text = widget.keyword;
    _searchController
        .addListener(() => widget.searchCallBack(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: appBarColor,
      elevation: 0.01,
      brightness: Brightness.dark,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: blackColor,
          size: 22,
        ),
        onPressed: () => widget.cancel(),
      ),
      titleSpacing: 0.0,
      title: SizedBox(
        height: 40,
        child: CupertinoTextField(
          controller: _searchController,
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
        ),
      ),
      actions: <Widget>[
        SizedBox(
          width: 70,
          child: FlatButton(
            textColor: Colors.blue,
            child: Text(
              '取消',
              style: TextStyle(fontSize: 14),
            ),
            onPressed: () => widget.cancel(),
          ),
        )
      ],
    );
  }
}

// 列表组件
class ContactsSearchResultListWidget extends StatefulWidget {
  final String keyword; // 搜索关键词
  final int type; // 查找的内容类型说明  0:联系人/1:群聊
  final List<NimSearchContactViewModel> models; // contactInfo/teamInfo

  static NimSearchContactViewModel _toModel(Map model, int type) {
    if (type == 0) {
      return ContactInfo.fromJson(model);
    }

    if (type == 1) {
      return Team.fromJson(model);
    }

    return null;
  }

  factory ContactsSearchResultListWidget(params) {
    List models = params['models'];
    return ContactsSearchResultListWidget._a(params['keyword'], params['type'],
        models.map((f) => _toModel(f, params['type'])).toList());
  }
  ContactsSearchResultListWidget._a(this.keyword, this.type, this.models)
      : assert(keyword.length > 0),
        assert(models.length > 0);
  @override
  ContactsSearchResultListState createState() {
    return ContactsSearchResultListState();
  }
}

class ContactsSearchResultListState
    extends State<ContactsSearchResultListWidget> {
  List _infos = [];
  ContactsearchresultBloc _bloc;
  @override
  void initState() {
    super.initState();
    _infos = widget.models;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // tile
  Widget _buildTile(NimSearchContactViewModel model) {
    double itemHeight = 72.1;

    return SizedBox(
      height: itemHeight,
      child: model.cell(() {
        Session session;
        if (model is ContactInfo) {
          session = Session(model.infoId, 0);
        }

        if (model is Team) {
          session = Session(model.teamId, 1);
        }

        // 点击了cell
        _bloc.add(TappedCellEvent(session));
      }),
    );
  }

  // item
  Widget _buildItem(int idx) {
    if (_infos.length > 0) {
      if (idx == 0) {
        return Container(
          height: 30,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          child: Text(widget.type == 0 ? '联系人' : '群聊'),
        );
      }
      // 因为在count的时候+1了，所以这里-1
      NimSearchContactViewModel model = _infos[idx - 1];
      return _buildTile(model);
    }

    return SizedBox(
      height: 300,
      child: Center(
        child: Text('未匹配到相关数据类型~'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: BlocProvider<ContactsearchresultBloc>(
      builder: (context) {
        _bloc = ContactsearchresultBloc();
        return _bloc;
      },
      child: Scaffold(
        appBar: ContactSearchBar(widget.keyword,
            () => _bloc.add(CancelSearchingEvent()), (text)=> _bloc.add(NewContactSearchEvent(widget.type, text))),
        body: BlocBuilder<ContactsearchresultBloc, ContactsearchresultState>(
          builder: (context, state) {

            if(state is ContactsSearchingResult) {
              _infos = state.contacts?? state.groups;
            }
            
            return ListView.separated(
              itemCount: _infos.length + 1,
              itemBuilder: (context, idx) => _buildItem(idx),
              separatorBuilder: (context, idx) => Divider(
                height: 0.1,
                indent: 12,
              ),
            );
          },
        ),
      ),
    ));
  }
}
