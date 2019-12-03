/// Created by chenyn 2019-12-03
/// 分享组件
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cajian/Base/CJUtils.dart';

/// 接口
cjShowSharePopView(BuildContext context, CJShareModel model) {
  showCupertinoModalPopup(
      context: context,
      builder: (context) => CJShare(
            model: model,
          ));
}

/// 分享类型
enum CJShareType {
  /// 文本
  Text,

  /// 图片
  Image,

  /// 链接
  Link,
}

/// 分享数据model
class CJShareModel {
  /// 类型
  CJShareType type;

  /// 图片数据
  Uint8List imgData;

  /// 链接地址
  String linkUrlString;

  CJShareModel(this.type, {this.imgData, this.linkUrlString});
}

/// share 组件
class CJShare extends StatefulWidget {
  final CJShareModel model;
  CJShare({Key key, this.model}) : super(key: key);

  @override
  _CJShareState createState() => _CJShareState();
}

class _CJShareState extends State<CJShare> {
  /// 分享给好友
  Widget _shareToFirends() {
    return GestureDetector(
      onTap: () {
        print('share to firend!');
      },
      child: Container(
        height: 70,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/icon_share_friend@2x.png',
              width: 44,
            ),
            Text(
              '好友',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  /// 分享到微信
  Widget _shareToWeChat() {
    return GestureDetector(
      onTap: () {
        print('share to wechat!');
      },
      child: Container(
        height: 70,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/icon_share_weixin@2x.png',
              width: 44,
            ),
            Text(
              '微信',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  /// 收藏
  Widget _shareToCollect() {
    return GestureDetector(
      onTap: () {
        print('share to collect!');
      },
      child: Container(
        height: 70,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/icon_share_collect@2x.png',
              width: 44,
            ),
            Text(
              '收藏',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  /// Safari打开
  Widget _shareToSafari() {
    return GestureDetector(
      onTap: () {
        print('share to safari!');
      },
      child: Container(
        height: 70,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/icon_share_safari@2x.png',
              width: 44,
            ),
            Text(
              '用Safari打开',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  /// 复制链接
  Widget _shareToLink() {
    return GestureDetector(
      onTap: () {
        print('share to link!');
      },
      child: Container(
        height: 70,
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'images/icon_share_copy@2x.png',
              width: 44,
            ),
            Text(
              '复制链接',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = getSize(context).width;

    List<Widget> actions = [
      _shareToFirends(),
      _shareToWeChat(),
    ];
    if (widget.model.type == CJShareType.Link) {
      actions.addAll([_shareToCollect(), _shareToSafari(), _shareToLink()]);
    } else if(widget.model.type == CJShareType.Text){
      actions.addAll([_shareToCollect()]);
    }else {
      actions.addAll([_shareToCollect()]);
    }
    return Container(
        padding: EdgeInsets.all(10),
        color: Color(0xdde5e5e5),
        constraints: BoxConstraints(maxHeight: 180, minWidth: w),
        child: Center(
          child: Wrap(
            direction: Axis.horizontal,
            alignment: WrapAlignment.start,
            spacing: 10,
            runSpacing: 10,
            runAlignment: WrapAlignment.center,
            children: actions,
          ),
        ));
  }
}
