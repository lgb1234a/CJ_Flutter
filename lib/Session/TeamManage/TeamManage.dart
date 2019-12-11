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
  TeammanageBloc _bloc;
  List _managers = [];

  @override
  void initState() {
    super.initState();
  }

  /// 设置管理员
  Widget _managerSetting() {
    return cell(
        Text('设置管理员'),
        Row(
          children: <Widget>[
            Text(_managers.length.toString() + '人'),
            Icon(Icons.arrow_forward_ios)
          ],
        ),
        () => _bloc.add(TeamManagerSetting()));
  }

  ///  群机器人
  Widget _teamRobots() {
    return cell(
        Text('群机器人'),
        Row(
          children: <Widget>[Text('点击查看'), Icon(Icons.arrow_forward_ios)],
        ),
        () => _bloc.add(TappedToRobotSetting()));
  }

  /// 群转让
  Widget _teamTransform() {
    return cell(
        Text('群转让'),
        Row(
          children: <Widget>[Text('点击设置'), Icon(Icons.arrow_forward_ios)],
        ),
        () => _bloc.add(TeamTransform()));
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
                    _teamRobots(),
                    Divider(
                      indent: 12,
                      height: 0.5,
                    ),
                    _teamTransform()
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
