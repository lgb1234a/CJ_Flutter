/**
 * created by chenyn 2019-11-7
 * 个人信息页
 */
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nim_sdk_util/nim_sdk_util.dart';
import './bloc/bloc.dart';
import './bloc/userinfo_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../../Base/CJUtils.dart';
import 'package:cajian/Login/LoginManager.dart';

class UserInfoPage extends StatefulWidget {
  final Map params;
  UserInfoPage(this.params);

  @override
  State<StatefulWidget> createState() {
    return UserInfoPageState();
  }
}

class UserInfoPageState extends State<UserInfoPage> {
  String _userId;
  double _cellH = 44;
  UserinfoBloc _bloc;
  bool _isMe = false;
  bool _isMyFriend = false;
  TextEditingController _aliasController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _userId = widget.params['user_id'];
    _initialStatus();
  }

  /// 初始化
  _initialStatus() async {
    String me = await LoginManager().getAccid();
    _isMe = _userId == me;

    /// 由于bloc无法管理appBar的状态，所以在这里刷新状态
    bool isMyFriend = await NimSdkUtil.isMyFriend(_userId);
    setState(() {
      _isMyFriend = isMyFriend;
    });
  }

  _requestFriend() async {
    /// 添加好友
    NotificationHandleType type = await NimSdkUtil.requestFriend(_userId);
    if (type == NotificationHandleType.NotificationHandleTypeOk) {
      // 添加成功 刷新页面
      setState(() {
        _isMyFriend = true;
      });
    }
  }

  /* 备注 */
  Widget _aliasSection(UserInfo info) {
    if (_isMe || !_isMyFriend) {
      return Container();
    }
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        color: Colors.white,
        height: _cellH,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('备注'),
            ),
            info.alias != null ? Text(info.alias) : SizedBox(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
      ),
      onTap: () {
        cjDialog(context, '设置备注',
            content: CupertinoTextField(
              controller: _aliasController,
              clearButtonMode: OverlayVisibilityMode.editing,
            ),
            handlers: [
              () {
                if (_aliasController.text.trim().isNotEmpty) {
                  _bloc.add(TouchedAlias(alias: _aliasController.text.trim()));
                }
              }
            ],
            handlerTexts: [
              '确定'
            ]);
      },
    );
  }

  /* 信息区块 */
  Widget _infoSection(UserInfo info) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: _cellH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text('生日'), Text(info.birth ?? '')],
            ),
          ),
          Divider(
            height: 0.5,
            indent: 12,
          ),
          Container(
            height: _cellH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text('邮箱'), Text(info.email ?? '')],
            ),
          ),
          Divider(
            height: 0.5,
            indent: 12,
          ),
          Container(
            height: _cellH,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[Text('签名'), Text(info.sign ?? '')],
            ),
          ),
        ],
      ),
    );
  }

  /* 头像区块 */
  Widget _avatarSection(UserInfo info) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(12),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: ()=> cjDialog(context, '易宝版暂不支持查看用户头像，敬请期待～'),
            child: info.avatarUrlString != null
              ? FadeInImage.assetNetwork(
                  image: info.avatarUrlString,
                  width: 44,
                  placeholder: 'images/icon_avatar_placeholder@2x.png',
                )
              : Image.asset(
                  'images/icon_avatar_placeholder@2x.png',
                  width: 44,
                ),
          ),
          Expanded(
            child: Container(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text(info.alias ?? info.showName),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                          ),
                          Image.asset(
                            info.gender == 2
                                ? 'images/icon_gender_female@2x.png'
                                : 'images/icon_gender_male@2x.png',
                            width: 14,
                          )
                        ],
                      ),
                    ),
                    Text('擦肩号：${info.cajianNo}'),
                    info.alias != null
                        ? Text('昵称：${info.showName}')
                        : SizedBox()
                  ],
                )),
          )
        ],
      ),
    );
  }

  /* 发送消息按钮 */
  Widget _sendMsgSection() {
    if (_isMe) return Container();

    if (!_isMyFriend) {
      /// 不是朋友，显示添加添加好友
      return Container(
        padding: EdgeInsets.all(22),
        child: CupertinoButton.filled(
          padding: EdgeInsets.all(10),
          child: Text('添加到通讯录'),
          onPressed: _requestFriend,
        ),
      );
    }
    return GestureDetector(
      child: Container(
        height: _cellH,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[Icon(Icons.send), Text('发消息')],
        ),
      ),
      onTap: () => _bloc.add(TouchedSendMsg()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: BlocProvider<UserinfoBloc>(
      create: (context) {
        _bloc = UserinfoBloc(userId: _userId)..add(FetchUserInfo());
        return _bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              FlutterBoost.singleton.closeCurrent();
            },
          ),
          title: Text(
            '详细资料',
            style: TextStyle(color: blackColor),
          ),
          actions: <Widget>[
            (_isMe || !_isMyFriend)
                ? Container()
                : IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      size: 33,
                    ),
                    onPressed: () => _bloc.add(TouchedMore()),
                  )
          ],
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: BlocBuilder<UserinfoBloc, UserinfoState>(
          builder: (context, state) {
            Widget body = Center(
              child: CupertinoActivityIndicator(),
            );

            // 加载ok
            if (state is UserInfoLoaded) {
              body = ListView(
                children: <Widget>[
                  _avatarSection(state.info),
                  Container(
                    height: 9,
                  ),
                  _aliasSection(state.info),
                  Container(
                    height: (_isMe || !_isMyFriend) ? 0 : 9,
                  ),
                  _infoSection(state.info),
                  Container(
                    height: 9,
                  ),
                  _sendMsgSection()
                ],
              );
            }

            // 点击头像
            if (state is FullScreenAvatar) {
              body = Offstage(
                child: state.image,
              );
            }
            return body;
          },
        ),
      ),
    ));
  }
}
