/// Created by chenyn 2019-12-6
/// 群成员列表

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import '../Base/CJUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';

class SessionMemberListPage extends StatefulWidget {
  final Map params;
  SessionMemberListPage({Key key, @required this.params}) : super(key: key);

  @override
  _SessionMemberListPageState createState() => _SessionMemberListPageState();
}

class _SessionMemberListPageState extends State<SessionMemberListPage> {
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int _searchBarHeight = 60;
  String _teamId;
  List<Map> _infos;
  bool _inSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _teamId = widget.params['teamId'];

    fetchData();

    _searchController.addListener(() {
      setState(() {
        _inSearching = _searchController.text.isNotEmpty;
      });
    });

    _scrollController.addListener(() {
      /// 隐藏键盘
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void fetchData() async {
    List<TeamMemberInfo> memberInfos =
        await NimSdkUtil.teamMemberInfos(_teamId);
    List<Future<Map>> mapFutures = memberInfos
        .map((f) async => {
              'memberInfo': f,
              'userInfo': await NimSdkUtil.userInfoById(userId: f.userId)
            })
        .toList();
    _infos = await Future.wait(mapFutures);
    setState(() {});
  }

  /// search bar
  Widget _buildSearchBar() {
    return Container(
      height: _searchBarHeight.toDouble(),
      color: mainBgColor,
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(minHeight: 40),
      child: CupertinoTextField(
        controller: _searchController,
        padding: EdgeInsets.symmetric(horizontal: 10),
        prefix: Container(
          padding: EdgeInsets.only(left: 10),
          child: Image.asset('images/icon_contact_search@2x.png'),
        ),
        placeholder: '搜索',
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(3.0))),
        clearButtonMode: OverlayVisibilityMode.editing,
      ),
    );
  }

  /// 构建item
  Widget _buildAvatar(TeamMemberInfo memberInfo, UserInfo userInfo) {
    int dt = (memberInfo.createTime * 1000).ceil();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(dt);

    String avatarStr = userInfo.avatarUrlString;
    Widget avatar = avatarStr == null
        ? Image.asset(
            'images/icon_avatar_placeholder@2x.png',
            width: 40,
          )
        : (avatarStr.startsWith('http')
            ? FadeInImage.assetNetwork(
                image: avatarStr,
                width: 40,
                placeholder: 'images/icon_avatar_placeholder@2x.png',
              )
            : Image.asset(
                avatarStr,
                width: 40,
              ));
    return GestureDetector(
      onTap: () {
        /// 点击了群成员头像,跳转群成员信息页
        FlutterBoost.singleton.open('member_info', urlParams: {
          'team_id': memberInfo.teamId,
          'member_id': memberInfo.userId
        }, exts: {
          'animated': true
        });
      },
      child: SizedBox(
        width: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            avatar,
            Text(
              memberInfo.nickName == null
                  ? userInfo.showName
                  : memberInfo.nickName,
              overflow: TextOverflow.ellipsis,
            ),
            Text(date.year.toString() +
                '-' +
                date.month.toString() +
                '-' +
                date.day.toString())
          ],
        ),
      ),
    );
  }

  /// 搜索结果列表
  Widget _searchResultList() {
    String key = _searchController.text;
    List<Map> memberSearchResult = _infos.where((f) {
      TeamMemberInfo memberInfo = f['memberInfo'];
      UserInfo userInfo = f['userInfo'];
      return (memberInfo.nickName != null &&
              memberInfo.nickName.contains(key)) ||
          userInfo.showName.contains(key);
    }).toList();

    return SliverList(
      key: Key('SliverFixedExtentList'),
      delegate: SliverChildListDelegate(memberSearchResult.map((f) {
        UserInfo userInfo = f['userInfo'];
        TeamMemberInfo memberInfo = f['memberInfo'];
        return ListTile(
          onTap: () => FlutterBoost.singleton.open('member_info', urlParams: {
            'team_id': memberInfo.teamId,
            'member_id': memberInfo.userId
          }, exts: {
            'animated': true
          }),
          leading: userInfo.avatarUrlString != null
              ? FadeInImage.assetNetwork(
                  image: userInfo.avatarUrlString,
                  width: 44,
                  placeholder: 'images/icon_avatar_placeholder@2x.png',
                )
              : Image.asset(
                  'images/icon_avatar_placeholder@2x.png',
                  width: 44,
                ),
          title: Text(memberInfo.nickName != null
              ? memberInfo.nickName
              : userInfo.showName),
        );
      }).toList()),
    );
  }

  /// 列表
  Widget _list() {
    if (_infos == null) return Container();

    return Expanded(
        child:
            CustomScrollView(controller: _scrollController, slivers: <Widget>[
      SliverAppBar(
        flexibleSpace: _buildSearchBar(),
        backgroundColor: mainBgColor,
      ),
      SliverPadding(padding: EdgeInsets.only(bottom: 10)),
      _inSearching
          ? _searchResultList()
          : SliverGrid(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              delegate: SliverChildListDelegate(
                _infos
                    .map((f) => _buildAvatar(f['memberInfo'], f['userInfo']))
                    .toList(),
              ),
            )
    ]));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '群成员',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: <Widget>[_list()],
        ),
      ),
    );
  }
}
