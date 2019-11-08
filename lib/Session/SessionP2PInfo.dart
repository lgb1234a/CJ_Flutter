/**
 * created by chenyn 2019-10-30
 * 点对点聊天的聊天信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc.dart';
import '../Base/CJUtils.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/cupertino.dart';

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
        children: <Widget>[
          avatar,
          Text(
            showName,
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }

  // p2p list cell
  Widget _buildItem(BuildContext context, int idx, dynamic state) {
    double screentW = getSize(context).width;

    if (state is P2PSessionInfoLoaded) {
      if (idx == 0) {
        // 用户信息区块
        UserInfo info = state.info;
        return Container(
          height: 70,
          width: screentW,
          child: Row(
            children: <Widget>[
              GestureDetector(
                child: _buildAvatar(info.avatarUrlString, info.showName),
                onTap: () =>
                    _bloc.add(TappedUserAvatar(userId: widget._session.id)),
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

      if (idx == 1) {
        return Container(
          width: screentW,
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('消息提醒'),
              CupertinoSwitch(
                value: state.notifyStatus,
                onChanged: (bool newValue) => _bloc.add(SwitchNotifyStatus(
                    session: widget._session, newValue: newValue)),
              ),
            ],
          ),
        );
      }

      if (idx == 2) {
        return Container(
          width: screentW,
          height: 40,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('聊天置顶'),
              CupertinoSwitch(
                value: state.isStickedOnTop,
                onChanged: (bool newValue) => _bloc.add(SwitchStickOnTopStatus(
                    session: widget._session, newValue: newValue)),
              ),
            ],
          ),
        );
      }
    }

    if (idx == 3) {
      // 清空聊天记录按钮
      return CupertinoButton.filled(
        child: Text('清空聊天记录'),
        onPressed: () {
          cjSheet(context, '警告', msg: '确定要清空聊天记录吗？', handlerTexts: [
            '确定'
          ], handlers: [
            () => _bloc.add(ClearChatHistory(session: widget._session))
          ]);
          // _bloc.add(ClearChatHistory(session: widget._session))
        },
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<SessioninfoBloc>(context);
    double top = topPadding(context);
    return Scaffold(
        body: BlocBuilder<SessioninfoBloc, SessioninfoState>(
      condition: (previousState, state) {
        return true;
      },
      builder: (context, state) {
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(12, top + 12, 12, 12),
          itemCount: 4,
          itemBuilder: (context, idx) => _buildItem(context, idx, state),
          separatorBuilder: (context, idx) => Container(
            height: 9,
          ),
        );
      },
    ));
  }
}