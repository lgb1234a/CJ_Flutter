/// Created by chenyn 2019-11-28
/// 二维码显示页
///
import 'package:flutter/material.dart';
import 'package:flutter_boost/flutter_boost.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Base/CJUtils.dart';

class QrCodePage extends StatefulWidget {
  final Map params;
  QrCodePage({@required this.params});

  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
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
        body: Center(
          child: QrImage(
            version: QrVersions.auto,
            data: widget.params['content'],
            embeddedImage: ip,
            embeddedImageStyle: QrEmbeddedImageStyle(size: embeddedImgSize),
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
      ),
    );
  }
}
