/// Created by chenyn 2019-12-9
/// 群管理页面

import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../../Base/CJUtils.dart';
import 'bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';

class TeamManagePage extends StatefulWidget {
  final Map params;
  TeamManagePage({Key key, this.params}) : super(key: key);

  @override
  _TeamManagePageState createState() => _TeamManagePageState();
}

class _TeamManagePageState extends State<TeamManagePage> {
  double indent = 12;
  TeammanageBloc _bloc;
  List _managers = [];

  @override
  void initState() {
    super.initState();
  }

  /// cell
  Widget _cell(Widget title, Widget accessoryView, Function onTap,
      {Widget subTitle}) {
    List<Widget> ws = subTitle == null ? [title] : [title, subTitle];

    return new GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: indent),
        constraints: BoxConstraints(minHeight: 46),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: ws,
              ),
            ),
            Container(child: accessoryView),
          ],
        ),
      ),
    );
  }

  /// 设置管理员
  Widget _managerSetting() {
    return _cell(
        Text('设置管理员'),
        Row(
          children: <Widget>[
            Text(_managers.length.toString() + '人'),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
        () {});
  }

  ///  群机器人
  Widget _teamRobots() {
    return _cell(
        Text('群机器人'),
        Row(
          children: <Widget>[Text('点击查看'), Icon(Icons.arrow_forward_ios)],
        ),
        () => _bloc.add(TappedToRobotSetting()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TeammanageBloc>(
        builder: (context) {
          _bloc = TeammanageBloc(teamId: widget.params['teamId'])..add(Fetch());
          return _bloc;
        },
        child: MaterialApp(
            home: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                FlutterBoost.singleton.closeCurrent();
              },
            ),
            title: Text(
              '群管理',
              style: TextStyle(color: blackColor),
            ),
            backgroundColor: mainBgColor,
            elevation: 0.01,
            iconTheme: IconThemeData.fallback(),
          ),
          body: BlocBuilder<TeammanageBloc, TeammanageState>(
            builder: (context, state) {
              if (state is DataLoaded) {
                _managers = state.managers;
                return ListView(
                  children: <Widget>[
                    _managerSetting(),
                    Container(height: 8),
                    _teamRobots()
                  ],
                );
              } else {
                return Center(
                  child: CupertinoActivityIndicator(),
                );
              }
            },
          ),
        )));
  }
}
