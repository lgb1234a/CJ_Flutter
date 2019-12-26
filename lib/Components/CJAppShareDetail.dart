/// Created by Chenyn 2019-12-26
/// 分享App气泡点击预览页
///

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_boost/flutter_boost.dart';
import '../Base/CJUtils.dart';

class CJAppShareDetailPage extends StatefulWidget {
  final Map params;
  CJAppShareDetailPage({Key key, this.params}) : super(key: key);

  @override
  _CJAppShareDetailPageState createState() => _CJAppShareDetailPageState();
}

class _CJAppShareDetailPageState extends State<CJAppShareDetailPage> {
  String _imgUrl;
  String _title;
  String _desc;
  String _webUrl;
  String _extention;

  @override
  void initState() {
    super.initState();

    _imgUrl = widget.params['imgUrl'];
    _title = widget.params['title'] ?? '';
    _desc = widget.params['desc'] ?? '暂无描述';
    _webUrl = widget.params['webUrl'] ?? '';
    _extention = widget.params['extention'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var headImg;
    if (_imgUrl == null) {
      headImg = Image.asset(
        'images/icon_share_safari@2x.png',
        width: 60,
      );
    } else {
      headImg = FadeInImage.assetNetwork(
        image: _imgUrl,
        placeholder: 'images/icon_share_safari@2x.png',
        width: 60,
      );
    }

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
            '详情',
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        body: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: <Widget>[
              headImg,
              Padding(
                padding: EdgeInsetsDirectional.only(top: 10),
              ),
              Text(
                _title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 10),
              ),
              Divider(
                indent: 12,
                height: 0.5,
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 20),
              ),
              Text(
                _desc,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 20),
              ),
              Container(
                child: CupertinoButton.filled(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('加入'),
                  onPressed: () {},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
