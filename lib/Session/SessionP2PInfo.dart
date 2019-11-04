/**
 * created by chenyn 2019-10-30
 * 点对点聊天的聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';

class SessionP2PInfo extends StatefulWidget {
  final Session _session;
  SessionP2PInfo(this._session);
  @override
  State<StatefulWidget> createState() {
    return SessionP2PInfoState();
  }
}

class SessionP2PInfoState extends State<SessionP2PInfo> {
  SessioninfoBloc _bloc;
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAvatar(String avatarStr, String showName) {
    Widget avatar = avatarStr.startsWith('http')
        ? Image.network(
            avatarStr,
            width: 40,
          )
        : Image.asset(
            avatarStr,
            width: 40,
          );
    return SizedBox(
      width: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[avatar, Text(showName)],
      ),
    );
  }

  // p2p list cell
  Widget _buildItem(BuildContext context, int idx, dynamic state) {
    double screentW = getSize(context).width;
    if (idx == 0) {
      if (state is UserInfoLoaded) {
        // 用户信息区块
        UserInfo info = state.info;
        return Container(
          height: 70,
          width: screentW,
          child: Row(
            children: <Widget>[
              GestureDetector(
                child: _buildAvatar(info.avatarUrlString, info.showName),
                onTap: () => _bloc.add(TappedUserAvatar()),
              ),
              GestureDetector(
                child:
                    _buildAvatar('images/icon_session_info_add@2x.png', '创建群聊'),
                onTap: () =>
                    _bloc.add(CreateGroupSession(userId: widget._session.id)),
              )
            ],
          ),
        );
      }
    }

    if (state is SessionNotifyStatusLoaded) {}

    if (state is SessionIsStickedOnTopLoaded) {}

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<SessioninfoBloc>(context);
    
    return Scaffold(body: BlocBuilder<SessioninfoBloc, SessioninfoState>(
      builder: (context, state) {
        return ListView.separated(
          itemCount: 4,
          itemBuilder: (context, idx) => _buildItem(context, idx, state),
          separatorBuilder: (context, idx) => Container(
            // color: Color(0xffe5e5e5),
            height: 9,
          ),
        );
      },
    ));
  }
}
