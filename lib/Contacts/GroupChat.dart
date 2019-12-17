/// Created by Chenyn 2019-12-16
/// 群聊页面

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/cupertino.dart';
import '../Login/LoginManager.dart';

class GroupChatPage extends StatefulWidget {
  GroupChatPage({Key key}) : super(key: key);

  @override
  _GroupChatState createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChatPage> {
  int _searchBarHeight = 50;
  int _segmentBarHeight = 30;
  bool _inSearching = false;
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<Team> _teams = [];

  /// 创建的
  List<TeamMemberInfo> _teamsOwning = [];

  /// 管理的
  List<TeamMemberInfo> _teamsManaging = [];

  /// 加入的
  List<TeamMemberInfo> _teamsJoined = [];

  /// 当前选中的
  List<Team> _teamsCurrent = [];

  /// 0:我创建的群  1:我管理的群   2:我加入的群
  int _type = 0;
  List<String> _typeString = ['我创建的群', '我管理的群', '我加入的群'];

  @override
  void initState() {
    super.initState();

    _fetchGroups();

    _searchController.addListener(() => _setSearchState());
    _scrollController.addListener(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 获取群聊列表
  _fetchGroups() async {
    String accid = await LoginManager().getAccid() ?? '';
    List<Team> teams = await NimSdkUtil.allMyTeams();
    List<Future<TeamMemberInfo>> futureMaps = teams
        .map((f) async => await NimSdkUtil.teamMemberInfoById(f.teamId, accid))
        .toList();
    List<TeamMemberInfo> teamInfos = await Future.wait(futureMaps);

    _teamsOwning = teamInfos.where((f) => f.type == 1).toList();
    _teamsManaging = teamInfos.where((f) => f.type == 2).toList();
    _teamsJoined = teamInfos.where((f) => f.type == 0).toList();

    _teams = teams;
    _updateDatasource();
  }

  /// 刷新数据源
  _updateDatasource() {
    if (_inSearching) {
      String keyword = _searchController.text.trim();
      setState(() {
        _teamsCurrent = _teams
            .where((f) => f.teamName != null && f.teamName.contains(keyword))
            .toList();
      });
    } else {
      setState(() {
        _teamsCurrent = _convertMemberToTeam(_type == 0
            ? _teamsOwning
            : (_type == 1 ? _teamsManaging : _teamsJoined));
      });
    }
  }

  /// 映射数据源类型
  List<Team> _convertMemberToTeam(List<TeamMemberInfo> infos) {
    return infos.map((f) {
      List<Team> mapped = _teams.where((t) => t.teamId == f.teamId).toList();
      if (mapped.isEmpty) {
        return null;
      }
      return mapped.first;
    }).toList();
  }

  /// 切换搜索状态
  _setSearchState() {
    if (!_inSearching) {
      _teamsCurrent = [];
      _inSearching = true;
    }

    _updateDatasource();
  }

  // search bar
  Widget _buildSearchBar() {
    return Container(
        height: _searchBarHeight.toDouble(),
        color: mainBgColor,
        padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
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
            _inSearching
                ? SizedBox(
                    width: 70,
                    child: FlatButton(
                      textColor: Colors.blue,
                      child: Text(
                        '取消',
                        style: TextStyle(fontSize: 14),
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _searchController.text = '';
                        _inSearching = false;
                        _updateDatasource();
                      },
                    ),
                  )
                : Container()
          ],
        ));
  }

  /// 选择条
  Widget _buildSegmentBar() {
    return Container(
      color: Colors.white,
      width: getSize(context).width,
      height: _segmentBarHeight.toDouble(),
      child: CupertinoSegmentedControl<int>(
        padding: EdgeInsets.symmetric(horizontal: 12),
        children: {
          0: Text(_typeString[0]),
          1: Text(_typeString[1]),
          2: Text(_typeString[2])
        },
        onValueChanged: (newValue) {
          _type = newValue;
          _updateDatasource();
        },
        groupValue: _type,
        selectedColor: Colors.blueAccent,
        unselectedColor: null,
        borderColor: Colors.transparent,
      ),
    );
  }

  /// 渲染item
  Widget _buildItem(BuildContext context, int idx) {
    Team t = _teamsCurrent[idx];
    if (t == null) {
      return Container();
    }
    return ListTile(
      leading: t.teamAvatar != null
          ? FadeInImage.assetNetwork(
              image: t.teamAvatar,
              width: 44,
              placeholder: 'images/icon_avatar_placeholder@2x.png',
            )
          : Image.asset(
              'images/icon_avatar_placeholder@2x.png',
              width: 44,
            ),
      title: Text(t.teamName ?? ''),
      onTap: () => FlutterBoost.singleton.open(
          'nativePage://android&iosPageName=CJSessionViewController',
          urlParams: {'id': t.teamId, 'type': 1},
          exts: {'animated': true}),
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          FlutterBoost.singleton.closeCurrent();
        },
      ),
      title: Text(
        '群聊',
        style: TextStyle(color: blackColor),
      ),
      backgroundColor: mainBgColor,
      elevation: 0.01,
      iconTheme: IconThemeData.fallback(),
    );

    return MaterialApp(
      home: Scaffold(
        appBar: appBar,
        body: Column(
          children: <Widget>[
            _buildSearchBar(),
            _inSearching ? Container() : _buildSegmentBar(),
            MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: Expanded(
                  flex: 1,
                  child: _teamsCurrent.isEmpty
                      ? Center(
                          child: Text.rich(
                            TextSpan(text: '暂无', children: [
                              TextSpan(
                                  text: _typeString[_type],
                                  style: TextStyle(color: Colors.red))
                            ]),
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          itemCount: _teamsCurrent.length,
                          itemBuilder: _buildItem,
                          separatorBuilder: (context, idx) => Divider(
                            indent: 12,
                            height: 0.5,
                          ),
                        ),
                )),
          ],
        ),
      ),
    );
  }
}
