/**
 * Created by chenyn on 2019-10-15
 * 通讯录搜索列表页（从点击更多 跳转过来）
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nim_sdk_util/nim_contactModel.dart';
import 'package:nim_sdk_util/nim_teamModel.dart';
import 'package:nim_sdk_util/nim_searchInterface.dart';
import 'package:cajian/Base/CJUtils.dart';

const double searchBarHeight = 70;

// 搜索框 app bar
class ContactSearchBar extends StatefulWidget implements PreferredSizeWidget {
  final String keyword;
  final Function back;
  ContactSearchBar(this.keyword, this.back);

  @override
  ContactSearchBarState createState() => ContactSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(searchBarHeight);
}

class ContactSearchBarState extends State<ContactSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化搜索框文案
    _searchController.text = widget.keyword;
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () => widget.back(),
      ),
      title: SizedBox(
        height: 40,
        child: CupertinoTextField(
          controller: _searchController,
        ),
      ),
    );
  }
}

// 列表组件
class ContactsSearchResultListWidget extends StatefulWidget {
  final String channelName; // channel
  final String keyword; // 搜索关键词
  final int type; // 查找的内容类型说明  0:联系人/1:群聊
  final List<CJSearchInterface> models; // contactInfo/teamInfo

  static CJSearchInterface _toModel(Map model) {
    if (model['type'] == 0) {
      return ContactInfo(model);
    }

    if (model['type'] == 1) {
      return TeamInfo(model);
    }

    return null;
  }

  factory ContactsSearchResultListWidget(params, channelName) {
    List models = params['models'];
    return ContactsSearchResultListWidget._a(params['keyword'], params['type'],
        models.map((f) => _toModel(f)).toList(), channelName);
  }
  ContactsSearchResultListWidget._a(
      this.keyword, this.type, this.models, this.channelName)
      : assert(keyword.length > 0),
        assert(models.length > 0);
  @override
  ContactsSearchResultListState createState() {
    return ContactsSearchResultListState();
  }
}

class ContactsSearchResultListState
    extends State<ContactsSearchResultListWidget> {
  MethodChannel _platform;
  @override
  void initState() {
    super.initState();
    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
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
      child: tile,
    );
  }

  // item
  Widget _buildItem(BuildContext context, int idx) {
    double screenWidth = getSize(context).width;
    // 因为在count的时候+1了，所以这里-1
    CJSearchInterface model = widget.models[idx - 1];
    if (idx == 0) {
      return Container(
        height: 30,
        width: screenWidth,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(widget.type == 0 ? '群聊' : '联系人'),
      );
    }
    if (model is TeamInfo) {
      return _buildTile(model.teamAvatar, model.teamName);
    }

    if (model is ContactInfo) {
      return _buildTile(model.avatarUrlString, model.showName);
    }
    return SizedBox(
      width: screenWidth,
      height: 300,
      child: Center(
        child: Text('未匹配到相关数据类型~'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ContactSearchBar(widget.keyword,
          () => _platform.invokeMethod('popFlutterViewController')),
      body: ListView.separated(
        itemCount: widget.models.length + 1,
        itemBuilder: (context, idx) => _buildItem(context, idx),
        separatorBuilder: (context, idx) => Divider(
          height: 0.1,
          indent: 12,
        ),
      ),
    );
  }
}
