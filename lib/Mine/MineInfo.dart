import 'package:flutter/material.dart';
import 'package:cajian/Base/CJUtils.dart';
import 'package:flutter_boost/flutter_boost.dart';
import './bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nim_sdk_util/Model/nim_model.dart';
import 'package:flutter/cupertino.dart';

class MineInfoWiget extends StatefulWidget {
  _MineInfoState createState() => _MineInfoState();
}

class _MineInfoState extends State<MineInfoWiget> {
  MineinfoBloc _bloc;
  UserInfo _userInfo;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _signController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  ///
  Widget _avatar() {
    Widget avatar = Image.asset(
      'images/icon_avatar_placeholder@2x.png',
      width: 44,
    );
    if (_userInfo != null && _userInfo.avatarUrlString != null) {
      avatar = FadeInImage.assetNetwork(
        image: _userInfo.avatarUrlString,
        width: 44,
        placeholder: 'images/icon_avatar_placeholder@2x.png',
      );
    }

    return Cell(
      Text('头像'),
      Row(
        children: <Widget>[
          avatar,
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
          )
        ],
      ),
      () => cjSheet(context, '替换头像', handlerTexts: [
              '拍照',
              '从相册'
            ], handlers: [
              () => _bloc.add(TappedAvatar(type: 0)),
              () => _bloc.add(TappedAvatar(type: 1))
            ]),
      minHeight: 64,
    );
  }

  ///
  Widget _phone() {
    return Cell(
        Text('手机号'),
        Row(
          children: <Widget>[
            _userInfo == null ? Container() : Text(_userInfo.mobile ?? ''),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
        () => cjDialog(context, '易宝版暂不支持修改手机号，敬请期待～'));
  }

  ///
  Widget _nickName() {
    return Cell(
        Text('昵称'),
        Row(
          children: <Widget>[
            _userInfo == null ? Container() : Text(_userInfo.showName ?? ''),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
        () => cjDialog(context, '修改昵称',
          content: CupertinoTextField(
            controller: _nameController,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
          handlers: [
            () {
              if (_nameController.text.trim().isNotEmpty) {
                _bloc.add(
                    UpdateNickName(name: _nameController.text.trim()));
              }
            }
          ],
          handlerTexts: [
            '确定'
          ]));
  }

  ///
  Widget _cajianNo() {
    return Cell(
        Text('擦肩号'),
        Row(
          children: <Widget>[
            _userInfo == null ? Container() : Text(_userInfo.cajianNo ?? ''),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
        () => cjDialog(context, '易宝版暂不支持修改擦肩号，敬请期待～'));
  }

  ///
  Widget _qrcode() {
    return Cell(
        Text('我的二维码'),
        Row(
          children: <Widget>[
            Image.asset(
              'images/icon_settings_gray_qr@2x.png',
              width: 44,
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
            )
          ],
        ),
        _userInfo == null ? null :
            () => FlutterBoost.singleton.open('qrcode', urlParams: {
                  'title': '我的二维码',
                  'content':
                      'https://api.youxi2018.cn/v2/jump/p/' + _userInfo.userId,
                  'embeddedImgAssetPath': _userInfo.avatarUrlString == null
                      ? 'images/icon_contact_groupchat@2x.png'
                      : _userInfo.avatarUrlString,
                }, exts: {
                  'animated': true
                }));
  }

  String genderTransString(int type) {
    if (type == 0) {
      //未知性别
      return '未知';
    } else if (type == 1) {
      return '男';
    } else {
      return '女';
    }
  }

  ///
  Widget _gender() {
    return Cell(
        Text('性别'),
        Row(children: <Widget>[
          _userInfo == null
              ? Container()
              : Text(genderTransString(_userInfo.gender)),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
          )
        ]),
        () => cjDialog(context, '易宝版暂不支持修改性别，敬请期待～'));
  }

  ///
  Widget _birth() {
    return Cell(
        Text('生日'),
        Row(children: <Widget>[
          _userInfo == null ? Container() : Text(_userInfo.birth ?? ''),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
          )
        ]),
        () => cjDialog(context, '易宝版暂不支持修改生日，敬请期待～'));
  }

  ///
  Widget _mail() {
    return Cell(
        Text('邮箱'),
        Row(children: <Widget>[
          _userInfo == null ? Container() : Text(_userInfo.email ?? ''),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
          )
        ]),
        () => cjDialog(context, '设置新的邮箱地址',
          content: CupertinoTextField(
            controller: _emailController,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
          handlers: [
            () {
              if (_emailController.text.trim().isNotEmpty) {
                _bloc.add(
                    UpdateEmail(email: _emailController.text.trim()));
              }
            }
          ],
          handlerTexts: [
            '确定'
          ]));
  }

  ///
  Widget _sign() {
    return Cell(
        Text('签名'),
        Row(children: <Widget>[
          _userInfo == null ? Container() : Text(_userInfo.sign ?? ''),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
          )
        ]),
        () => cjDialog(context, '设置新的签名',
          content: CupertinoTextField(
            controller: _signController,
            clearButtonMode: OverlayVisibilityMode.editing,
          ),
          handlers: [
            () {
              if (_signController.text.trim().isNotEmpty) {
                _bloc.add(
                    UpdateSign(sign: _signController.text.trim()));
              }
            }
          ],
          handlerTexts: [
            '确定'
          ]));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider<MineinfoBloc>(
          create: (BuildContext context) {
            _bloc = MineinfoBloc()..add(FetchUserInfo());
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
                  '个人信息',
                  style: TextStyle(color: blackColor),
                ),
                backgroundColor: mainBgColor,
                elevation: 0.01,
                iconTheme: IconThemeData.fallback(),
              ),
              body: BlocBuilder<MineinfoBloc, MineinfoState>(
                builder: (context, state) {
                  if (state is UserInfoLoaded) {
                    _userInfo = state.userInfo;
                  }
                  return ListView(
                    children: <Widget>[
                      _avatar(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _phone(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _nickName(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _cajianNo(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _qrcode(),
                      Container(
                        height: 8,
                      ),
                      _gender(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _birth(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _mail(),
                      Divider(
                        indent: 12,
                        height: 0.5,
                      ),
                      _sign()
                    ],
                  );
                },
              ))),
    );
  }
}
