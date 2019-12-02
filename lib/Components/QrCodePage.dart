/// Created by chenyn 2019-11-28
/// 二维码显示页
///
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Base/CJUtils.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;

class QrCodePage extends StatefulWidget {
  final Map params;
  QrCodePage({@required this.params});

  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  GlobalKey _qrCodeKey = new GlobalKey();

  /// 保存到手机相册
  void _saveCodeToAlbum() async {
    /// 拿到图层
    RenderRepaintBoundary boundary =
        _qrCodeKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();

    FlutterBoost.singleton.channel
        .sendEvent('saveImageToAlbum', {'img_data': pngBytes});
  }

  /// 分享二维码
  void _shareCode() {
    
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.params.containsKey('title') ? widget.params['title'] : '二维码';
    if (!widget.params.containsKey('content')) return Container();

    String avatar = widget.params['embeddedImgAssetPath'];
    ImageProvider ip;
    if (avatar.startsWith('http'))
      ip = NetworkImage(avatar);
    else
      ip = AssetImage(avatar);

    Size embeddedImgSize = Size(44, 44);
    if (widget.params.containsKey('embeddedImgSize')) {
      double s = widget.params['embeddedImgSize'];
      embeddedImgSize = Size(s, s);
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
            title,
            style: TextStyle(color: blackColor),
          ),
          backgroundColor: mainBgColor,
          elevation: 0.01,
          iconTheme: IconThemeData.fallback(),
        ),
        backgroundColor: Color(0xffe5e5e5),
        body: Center(
          child: Container(
            height: 300,
            width: 300,
            child: Column(
              children: <Widget>[
                RepaintBoundary(
                  key: _qrCodeKey,
                  child: QrImage(
                    version: QrVersions.auto,
                    data: widget.params['content'],
                    embeddedImage: ip,
                    embeddedImageStyle:
                        QrEmbeddedImageStyle(size: embeddedImgSize),
                    size: 200,
                    gapless: false,
                    errorStateBuilder: (cxt, err) {
                      return Container(
                        child: Center(
                          child: Text(
                            "二维码解析出错了～",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      CupertinoButton(
                        color: Colors.white,
                        padding: EdgeInsets.all(10),
                        minSize: 44,
                        child: Container(
                          child: Text(
                            '保存到手机',
                            style: TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          width: 100,
                        ),
                        onPressed: _saveCodeToAlbum,
                      ),
                      CupertinoButton(
                        color: Colors.blue,
                        padding: EdgeInsets.all(10),
                        minSize: 44,
                        child: Container(
                          child: Text(
                            '分享',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                          width: 100,
                        ),
                        onPressed: _shareCode,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
