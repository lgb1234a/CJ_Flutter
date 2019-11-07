/**
 * created by chenyn 2019-11-7
 * 个人信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import './bloc/bloc.dart';

class UserInfoPage extends StatefulWidget {
  final Map params;
  final String channelName;
  UserInfoPage(this.params, this.channelName);

  @override
  State<StatefulWidget> createState() {
    return UserInfoPageState();
  }
}

class UserInfoPageState extends State<UserInfoPage> {
  MethodChannel _platform;
  String _userId;

  @override
  void initState() {
    super.initState();

    _platform = MethodChannel(widget.channelName);
    _platform.setMethodCallHandler(handler);
    _userId = widget.params['user_id'];
  }

  // Native回调用
  Future<dynamic> handler(MethodCall call) async {
    debugPrint(call.method);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: BlocProvider<UserinfoBloc>(
      builder: (context) =>
          UserinfoBloc(mc: _platform)..add(FetchUserInfo(userId: _userId)),
      child: Scaffold(
        body: Center(
          child: Text('个人信息页'),
        ),
      ),
    ));
  }
}
